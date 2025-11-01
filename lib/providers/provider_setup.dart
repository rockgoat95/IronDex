import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/providers/review_like_provider.dart';
import 'package:irondex/services/repositories/brand_repository.dart';
import 'package:irondex/services/repositories/machine_repository.dart';
import 'package:irondex/services/repositories/review_repository.dart';
import 'package:irondex/services/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> buildAppProviders(ServiceLocator services) {
  return [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    Provider<BrandRepository>.value(value: services.brandRepository),
    Provider<MachineRepository>.value(value: services.machineRepository),
    Provider<ReviewRepository>.value(value: services.reviewRepository),
    ChangeNotifierProxyProvider2<
      AuthProvider,
      MachineRepository,
      MachineFavoriteProvider
    >(
      create: (_) => MachineFavoriteProvider(),
      update: (_, auth, repository, previous) {
        final provider = previous ?? MachineFavoriteProvider();
        provider.updateDependencies(authProvider: auth, repository: repository);
        return provider;
      },
    ),
    ChangeNotifierProxyProvider2<
      AuthProvider,
      ReviewRepository,
      ReviewLikeProvider
    >(
      create: (_) => ReviewLikeProvider(),
      update: (_, auth, repository, previous) {
        final provider = previous ?? ReviewLikeProvider();
        provider.updateDependencies(authProvider: auth, repository: repository);
        return provider;
      },
    ),
  ];
}
