require_relative '../../../test/test_helper'
require_relative '../lib/samson_kubernetes/hash_kuber_selector'
require 'celluloid/test'

# Mock up vault client
class VaultClient
  def logical
    @logical ||= Logical.new
  end

  def self.vault_response_object(data)
    Response.new(data)
  end

  def initialize
    @expected = {}
    @set = {}
  end

  def list(key)
    @expected.delete("list-#{key}") || raise(KeyError, "list-#{key} not registered")
  end

  def read(key)
    Response.new(@expected.delete(key) || raise(KeyError, "#{key} not registered"))
  end

  def delete(key)
    @set[key] = nil
    true
  end

  def write(key, body)
    @set[key] = body
    true
  end

  # test hooks
  def clear
    @set.clear
    @expected.clear
  end

  def expect(key, value)
    @expected[key] = value
  end

  attr_reader :set

  def verify!
    @expected.keys.must_equal([], "Expected calls missed: #{@expected.keys}")
  end

  class Response
    attr_accessor :lease_id, :lease_duration, :renewable, :data, :auth
    def initialize(data)
      self.lease_id = nil
      self.lease_duration = nil
      self.renewable = nil
      self.auth = nil
      self.data = data
    end

    def to_h
      instance_values.symbolize_keys
    end
  end
end

class ActiveSupport::TestCase
  def self.it_responds_with_unauthorized(&block)
    it 'responds with unauthorized' do
      instance_eval(&block)
      @unauthorized.must_equal true, 'Request should get unauthorized'
    end
  end

  def self.it_responds_successfully(&block)
    it 'responds successfully' do
      instance_eval(&block)
      assert_response :success
    end
  end

  def self.it_responds_with_bad_request(&block)
    it 'responds with 400 Bad Request' do
      instance_eval(&block)
      assert_response :bad_request
    end
  end

  def self.it_should_raise_an_exception(&block)
    it 'should raise an exception' do
      assert_raises Exception do
        instance_eval(&block)
      end
    end
  end

  def with_example_kube_config
    Tempfile.open('config') do |t|
      config = {
        'apiVersion' => 'v1',
        'users' => nil,
        'clusters' => [
          {
            'name' => 'somecluster',
            'cluster' => { 'server' => 'http://k8s.example.com' }
          }
        ],
        'contexts' => [
          {
            'name' => 'default',
            'context' => { 'cluster' => 'somecluster', 'user' => '' }
          }
        ],
        'current-context' => 'default'
      }
      t.write(config.to_yaml)
      t.flush
      yield t.path
    end
  end

  def create_kubernetes_cluster(attr = {})
    Kubernetes::Cluster.any_instance.stubs(connection_valid?: true)
    cluster_attr = {
      name: 'Foo',
      config_filepath: File.join(File.dirname(__FILE__), 'cluster_config.yml'),
      config_context: 'test'
    }.merge(attr)
    Kubernetes::Cluster.create!(cluster_attr)
  end

  def kubernetes_fake_raw_template
    template = {
      'kind' => 'Deployment',
      'spec' => {
        'template' => {
          'metadata' => {'labels' => {'pre_defined' => 'foobar', 'project' => 'foobar', 'role' => 'app-server'}},
          'spec' => {'containers' => [{}]}
        },
        'selector' => {'matchLabels' => {'pre_defined' => 'foobar', 'project' => 'foobar', 'role' => 'app-server'}}
      },
      'metadata' => {
        'name' => 'test',
        'labels' => {'project' => 'foobar', 'role' => 'app-server'}
      }
    }
    Kubernetes::ReleaseDoc.any_instance.stubs(raw_template: template.to_yaml)
  end

  private

  def read_kubernetes_sample_file(file_name)
    File.read("#{Rails.root}/plugins/kubernetes/test/samples/#{file_name}")
  end
end
