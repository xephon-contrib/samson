samson.directive('envVarScopeSelect', function() {
  return {
    restrict: 'E',
    replace: true,
    templateUrl: 'admin/env_var_groups/_env_var_scope_select.tmpl.html',

    link: function($scope, $element, attrs) {
      console.log('scope', $element, attrs.selected);
    }
  };
});
