import "package:mcquenji_core/mcquenji_core.dart";
import "package:flutter_modular/flutter_modular.dart";

class FirebaseModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];
}
