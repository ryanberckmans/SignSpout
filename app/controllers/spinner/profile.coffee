`import Ember from 'ember'`

# At this time, SpinnerProfileController only exists to give averageRating() a home.
# Some notes:
#   1. average rating is only used on spinner/profile.hbs; there isn't a way for a Business to see the rating of an employed Spinner
#  2. it isn't clear where averageRating should be get or set.
#      2a. as a computed property, averageRating can't live on the Spinner model
#      2b. if we did want to store averageRating in firebase, and recalculate it each time a SpinnerShift.spinnerRating was set, we must consider that the Business setting the rating naively must access every SpinnerShift.
#      2c. the other option, to store averageRating in firebase as a Spinner model property, is to also maintain 'ratingCount'. When a Business sets a SpinnerRating, the new average can be computed via (oldCount * oldAverage + newSpinnerRating) / (oldCount+1). In this way, we can keep the average up to date without the Business having a list of every spinner.spinnerShift. Care must be taken to ensure that oldCount/oldAverage aren't de-sync'd, corrupting the 'rolling average'.
SpinnerProfileController = Ember.ObjectController.extend
  averageRating: null
  averageRatingObserver: (->
    _this = this
    ratingTotal = 0
    ratingCount = 0
    @get('spinnerShifts').then (spinnerShifts) ->
      spinnerShifts.forEach (spinnerShift) ->        
        rating = spinnerShift.get('spinnerRating')
        if rating?
          ratingTotal += rating 
          ratingCount  += 1
      _this.set 'averageRating', (Math.round(10 * ratingTotal / ratingCount) / 10)
  ).observes 'spinnerShifts.@each.spinnerRating'

`export default SpinnerProfileController`
