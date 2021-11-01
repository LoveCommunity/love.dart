
/// A holder of state, oldState and event of a moment
class Moment<State, Event> {
  final State state;
  final State? oldState;
  final Event? event;
  const Moment(this.state, this.oldState, this.event);
}
