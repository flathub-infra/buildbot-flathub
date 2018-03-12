# Register new module
class App extends App
    constructor: ->
        return [
            'ui.router'
            'ui.bootstrap'
            'ngAnimate'
            'guanlecoja.ui'
            'bbData'
        ]


class State extends Config
    constructor: ($stateProvider, glMenuServiceProvider, bbSettingsServiceProvider) ->

        # Name of the state
        name = 'flathub'

        # Menu configuration
        glMenuServiceProvider.addGroup
            name: name
            caption: 'Flathub View'
            icon: 'coffee'
            order: 5

        # Configuration
        cfg =
            group: name
            caption: 'Flathub View'

        # Register new state
        state =
            controller: "#{name}Controller"
            controllerAs: "c"
            templateUrl: "flathub_view/views/#{name}.html"
            name: name
            url: "/#{name}"
            data: cfg

        $stateProvider.state(state)

        bbSettingsServiceProvider.addSettingsGroup
            name: 'Flathub'
            caption: 'Flathub related settings'
            items: [
                type: 'integer'
                name: 'testSetting'
                caption: 'A test setting'
                default_value: 200
            ]

class Flathub extends Controller
    constructor: (@$scope, $q, @$window, dataService, bbSettingsService, resultsService,
        @$uibModal, @$timeout) ->
        angular.extend this, resultsService
        settings = bbSettingsService.getSettingsGroup('Flathub')
        @testSetting = settings.testSetting.value

        @buildLimit = 100
        @changeLimit = 100
        @data = dataService.open().closeOnDestroy(@$scope)
        @_infoIsExpanded = {}
        @$scope.all_builders = @all_builders = @data.getBuilders()
        @$scope.builders = @builders = []
        @$scope.builds = @builds = @data.getBuilds
            property: ["got_revision"]
            limit: @buildLimit
            order: '-started_at'
        @changes = @data.getChanges({limit: @changeLimit, order: '-changeid'})
        @buildrequests = @data.getBuildrequests({limit: @buildLimit, order: '-submitted_at'})
        @buildsets = @data.getBuildsets({limit: @buildLimit, order: '-submitted_at'})

        @builds.onChange = @changes.onChange = @buildrequests.onChange = @buildsets.onChange = @onChange

    onChange: (s) =>
        # if there is no data, no need to try and build something.
        if @builds.length == 0 or @all_builders.length == 0 or not @changes.$resolved or
                @buildsets.length == 0 or @buildrequests == 0
            return
        if not @onchange_debounce?
            @onchange_debounce = @$timeout(@_onChange, 100)

    _onChange: =>
        @onchange_debounce = undefined
        # we only display builders who actually have builds
        for build in @builds
            @all_builders.get(build.builderid).hasBuild = true
