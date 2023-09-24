import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:docu_diary/models/models.dart';

part 'event.dart';
part 'state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  TokenDao _tokenDao = TokenDao();
  ClassDao _classDao = ClassDao();
  UserDao _userDao = UserDao();
  SelectedClassDao _classeSelected = SelectedClassDao();
  TokenBloc() : super(TokenLoadInProgress());

  @override
  Stream<TokenState> mapEventToState(TokenEvent event) async* {
    if (event is LoadToken) {
      Token? token = await _tokenDao.getToken();
      yield TokenLoadSuccess(token: token);
    } else if (event is TokenAdded) {
      yield* _mapTokenAddedToState(event);
    } else if (event is UserLogout) {
      yield* _mapUserLogoutToState(event);
    }
  }

  Stream<TokenState> _mapTokenAddedToState(TokenAdded event) async* {
    await _tokenDao.delete();
    await _tokenDao.insert(event.token);
    yield TokenLoadSuccess(token: event.token);
  }

  Stream<TokenState> _mapUserLogoutToState(UserLogout event) async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _tokenDao.delete();
    await _userDao.delete();
    await _classDao.deleteAll();
    await _classeSelected.deleteAll();
  }
}
