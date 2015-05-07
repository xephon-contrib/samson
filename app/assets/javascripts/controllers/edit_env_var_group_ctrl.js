samson.controller('editEnvVarGroupCtrl', function ($scope, $http, $location) {
  'use strict';

  $scope.group = { name: '', environment_variables: [] };
  $scope.scope_options = [];
  $scope.envNewKey = '';
  $scope.envNewValue = '';
  $scope.envNewScope = 0;
  $scope.errorMessage = '';

  $scope.addVar = function () {
    if ($scope.envNewKey.length && $scope.envNewValue.length) {
      $scope.group.environment_variables.push(
        { key: $scope.envNewKey, value: $scope.envNewValue, scope: $scope.envNewScope });
      $scope.envNewKey = '';
      $scope.envNewValue = '';
      $scope.envNewScope = 0;
    }
  };

  $scope.removeVar = function (env) {
    $scope.group.environment_variables = _.reject($scope.group.environment_variables, function (item) {
      return item.key == env.key && item.selected == env.selected;
    });
  };

  $scope.saveGroup = function () {
    console.log('Saving Group!', $scope.envVars);
    var data = {
      environment_variable_group: {
        name: $scope.group.name,
        environment_variables_attributes: $scope.group.environment_variables
      }
    };

    if ($scope.group.id) {
      console.log('URL: ', '/admin/environment_variable_groups/' + $scope.group.id + '.json');
      var promise = $http.put('/admin/environment_variable_groups/' + $scope.group.id + '.json', data);
    } else {
      var promise = $http.post('/admin/environment_variable_groups.json', data);
    }

    promise.success(function () {
      console.log('Successfully saved!');
      window.location.pathname = '/admin/environment_variable_groups';
    }).error(function(data) {
      console.log('Failed save!', data);
      $scope.errorMessage = data.msg;
    });
  };

  $scope.getEnvironmentVarGroup = function() {
    if ('/admin/environment_variable_groups/new' != $location.path()) {
      $http.get($location.path() + '.json').success(function (result) {
        console.log('Got getEnvironmentVarGroup response:', result);
        $scope.group = result;
      });
    }
  };

  $scope.showErrorMessage = function() {
    return $scope.errorMessage.length == 0;
  };

  $scope.clearError = function() {
    $scope.errorMessage = '';
  };

  function init() {
    $http.get('/admin/environment_variable_groups/options_for_scope_select.json').success(function (result) {
      console.log('Got select options: ', result);
      $scope.scope_options = result.options;
      $scope.getEnvironmentVarGroup();
    });
  }

  init();
});
