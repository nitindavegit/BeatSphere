import 'dart:io';
import 'dart:ui';

import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repository/home_local_repository.dart';
import 'package:client/features/home/repository/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(Ref ref) async {
  final token = ref.watch(
    currentUserNotifierProvider.select((user) => user!.token),
  );
  final res = await ref.watch(homeRepositoryProvider).getAllSong(token: token);
  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<SongModel>> getFavSongs(Ref ref) async {
  final token = ref.watch(
    currentUserNotifierProvider.select((user) => user!.token),
  );
  final res = await ref
      .watch(homeRepositoryProvider)
      .getAllFavSong(token: token);
  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
class HomeViewmodel extends _$HomeViewmodel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;
  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required Color selectedColor,
  }) async {
    state = AsyncValue.loading();
    final res = await _homeRepository.uploadSong(
      selectedAudio: selectedAudio,
      selectedThumbnail: selectedThumbnail,
      songName: songName,
      artist: artist,
      hexCode: rgbToHex(selectedColor),
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
        l.message,
        StackTrace.current,
      ),
      Right(value: final r) => state = AsyncValue.data(r),
    };
    print(val);
  }

  List<SongModel> getRecentlyPlayedSongs() {
    return _homeLocalRepository.loadSongs();
  }

  Future<void> favSong({required String songId}) async {
    state = AsyncValue.loading();
    final res = await _homeRepository.favouriteSongs(
      songId: songId,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
        l.message,
        StackTrace.current,
      ),
      Right(value: final r) => _favSongSuccess(r, songId),
    };
    print(val);
  }

  AsyncValue _favSongSuccess(bool isFavourated, String songId) {
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    if (isFavourated) {
      userNotifier.addUser(
        ref
            .read(currentUserNotifierProvider)!
            .copyWith(
              favourites: [
                ...ref.read(currentUserNotifierProvider)!.favourites,
                FavSongModel(id: '', song_id: songId, user_id: ''),
              ],
            ),
      );
    } else {
      userNotifier.addUser(
        ref
            .read(currentUserNotifierProvider)!
            .copyWith(
              favourites: ref
                  .read(currentUserNotifierProvider)!
                  .favourites
                  .where((fav) => fav.song_id != songId)
                  .toList(),
            ),
      );
    }
    ref.invalidate(getFavSongsProvider);
    return state = AsyncValue.data(isFavourated);
  }
}
