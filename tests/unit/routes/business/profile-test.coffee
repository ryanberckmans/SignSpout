`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'route:business/profile', 'BusinessProfileRoute', {
  # Specify the other units that are required for this test.
  # needs: ['controller:foo']
}

test 'it exists', ->
  route = @subject()
  ok route
