`import Ember from 'ember'`
`import AuthenticatedRouteMixin from '../mixins/authenticated-route'`

ApplicationRoute = Ember.Route.extend AuthenticatedRouteMixin,
  actions:
    loginWithEmail: ->
      @get('auth').loginWithEmail 'ryanberckmans@gmail.com', 'password'

    logout: ->
      @get('auth').logout()

`export default ApplicationRoute`
