beforeEach ->
    module ($provide) ->
        $provide.service '$uibModal', -> open: ->
        null
    module ($provide) ->
        $provide.service 'resultsService', -> results2class: ->
        null

    # Mock bbSettingsProvider
    module ($provide) ->
        $provide.provider 'bbSettingsService', class
            group = {}
            addSettingsGroup: (g) -> g.items.map (i) ->
                if i.name is 'lazy_limit_waterfall'
                    i.default_value = 2
                group[i.name] = value: i.default_value
            $get: ->
                getSettingsGroup: ->
                    return group
                save: ->
        null
    module 'flathub_view'

describe 'Flathub view', ->
    $state = null
    beforeEach inject ($injector) ->
        $state = $injector.get('$state')

    it 'should register a new state with the correct configuration', ->
        name = 'flathub'
        state = $state.get().pop()
        data = state.data
        expect(state.controller).toBe("#{name}Controller")
        expect(state.controllerAs).toBe('c')
        expect(state.templateUrl).toBe("flathub_view/views/#{name}.html")
        expect(state.url).toBe("/#{name}")

