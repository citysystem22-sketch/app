import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/models/home_model.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomePage extends HomeEvent {}

class RefreshHomeSection extends HomeEvent {
  final String sectionId;

  const RefreshHomeSection(this.sectionId);

  @override
  List<Object?> get props => [sectionId];
}

class RefreshHomePage extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomePageData data;
  final bool isRefreshing;

  const HomeLoaded({
    required this.data,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [data, isRefreshing];

  HomeLoaded copyWith({
    HomePageData? data,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      data: data ?? this.data,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeDataSource _dataSource;

  HomeBloc({HomeDataSource? dataSource})
      : _dataSource = dataSource ?? HomeDataSource(),
        super(HomeInitial()) {
    on<LoadHomePage>(_onLoadHomePage);
    on<RefreshHomePage>(_onRefreshHomePage);
    on<RefreshHomeSection>(_onRefreshSection);
  }

  Future<void> _onLoadHomePage(
    LoadHomePage event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final data = await _dataSource.getHomePageData();
      emit(HomeLoaded(data: data));
    } catch (e) {
      emit(HomeError('Nie udało się załadować strony głównej: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshHomePage(
    RefreshHomePage event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
      try {
        final data = await _dataSource.getHomePageData();
        emit(HomeLoaded(data: data));
      } catch (e) {
        emit(currentState.copyWith(isRefreshing: false));
      }
    }
  }

  Future<void> _onRefreshSection(
    RefreshHomeSection event,
    Emitter<HomeState> emit,
  ) async {
    // Could implement section-specific refresh
    // For now, refresh entire page
    add(RefreshHomePage());
  }

  @override
  Future<void> close() {
    _dataSource.dispose();
    return super.close();
  }
}