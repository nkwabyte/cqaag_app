enum EventCategory {
  news('NEWS'),
  insights('INSIGHTS'),
  announcement('ANNOUNCEMENT'),
  training('TRAINING')
  ;

  final String label;
  const EventCategory(this.label);
}
