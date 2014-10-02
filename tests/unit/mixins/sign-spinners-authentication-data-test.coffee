`import Ember from 'ember'`
`import SignSpinnersAuthenticationDataMixin from 'sign-spinners/mixins/sign-spinners-authentication-data'`

module 'SignSpinnersAuthenticationDataMixin'

# Replace this with your real tests.
test 'it works', ->
  SignSpinnersAuthenticationDataObject = Ember.Object.extend SignSpinnersAuthenticationDataMixin
  subject = SignSpinnersAuthenticationDataObject.create()
  ok subject
