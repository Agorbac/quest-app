class ActorTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :game, optional: true

  RATES = {
    'photo' => 50,
    'upsell' => 100,
    'review_aggr' => 50,
    'review_yandex' => 100,
    'late_15' => -200,
    'late_game' => -500,
    'dirty' => -500,
    'no_report' => -300,
    'report_error' => -100,
    'no_upsell' => -200,
    'light_on' => -200,
    'no_consumables' => -100,
    'no_breakage_report' => -200,
    'skip_warned' => -1000,
    'dislike' => -300,
    'repair' => 500,
    'replacement' => 300,
    'initiative' => 500,
    'like' => 300
  }
end