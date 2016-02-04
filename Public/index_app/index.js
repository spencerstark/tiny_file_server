var indexApp = angular.module('indexApp',[]);

indexApp.controller('greetingController', ['$scope', '$http', '$location', function($scope, $http, $location){
	$scope.dataObject = {};
	$scope.greeting = "hello";
	console.log($location);
	$http.get('http://localhost:4567/files').then(getDataSuccess, getDataError);

	function getDataSuccess(responseObject) {
		console.log(responseObject);
		$scope.dataObject = responseObject;
	}

	function getDataError(responseObject) {
		console.error("getData request error:", responseObject);
	}
}])

indexApp.directive('myFirstDirective', function(){
	// Runs during compile
	return {
		restrict: 'E', // E = Element, A = Attribute, C = Class, M = Comment
		template: "<div>We've made our very first directive. It's boring, but it's ours!</div>",
	};
});


indexApp.directive('imageContainer', function(){
	// Runs during compile
	return {
		// name: '',
		// priority: 1,
		// terminal: true,
		// scope: {}, // {} = isolate, true = child, false/undefined = no change
		// controller: function($scope, $element, $attrs, $transclude) {},
		// require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
		restrict: 'E', // E = Element, A = Attribute, C = Class, M = Comment
		template: "<div class='image_container'>{{file}}</div>",
		// templateUrl: '',
		// replace: true,
		// transclude: true,
		// compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
	};
});