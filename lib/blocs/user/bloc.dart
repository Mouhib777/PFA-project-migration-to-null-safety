import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/models/models.dart';
part 'event.dart';
part 'state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserDao _userDao = UserDao();

  UserBloc() : super(UserLoadInProgress());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUser) {
      yield* _mapLoadUserToState(event);
    } else if (event is UserAdded) {
      yield* _mapUserAddedToState(event);
    }
  }

  Stream<UserState> _mapLoadUserToState(LoadUser event) async* {
    final User? user = await _userDao.getUser();
    yield UserLoadSuccess(user!);
  }

  Stream<UserState> _mapUserAddedToState(UserAdded event) async* {
    await _userDao.delete();
    await _userDao.insert(event.user);
    yield UserLoadSuccess(event.user);
  }
}
