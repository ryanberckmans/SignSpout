`import DS from 'ember-data'`

Business = DS.Model.extend
  name: DS.attr 'string'


Business.reopenClass
  FIXTURES: [
    { name: "Larry's Giant Subs" }
    { name: "Cricket Wireless" }
  ]

`export default Business`
