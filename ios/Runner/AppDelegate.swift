import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Debug: Verificar se o arquivo existe
    let bundlePath = Bundle.main.bundlePath
    print("📁 Bundle path: \(bundlePath)")
    
    // Listar arquivos no bundle para debug
    if let contents = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) {
      let plistFiles = contents.filter { $0.contains("GoogleService") }
      print("📄 GoogleService files found: \(plistFiles)")
    }
    
    // Tentar carregar API Key do GoogleService-Info.plist
    var apiKey: String?
    
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
      print("✅ GoogleService-Info.plist encontrado em: \(path)")
      
      if let plist = NSDictionary(contentsOfFile: path) {
        print("✅ Plist carregado com sucesso")
        print("🔑 Chaves disponíveis: \(plist.allKeys)")
        
        if let key = plist["API_KEY"] as? String {
          apiKey = key
          print("✅ API Key encontrada: \(String(key.prefix(10)))...")
        } else {
          print("❌ API_KEY não encontrada no plist")
        }
      } else {
        print("❌ Erro ao carregar o plist")
      }
    } else {
      print("❌ GoogleService-Info.plist não encontrado no bundle")
    }
    
    // Fallback para API Key hardcoded se não conseguir carregar do plist
    if apiKey == nil {
      apiKey = "AIzaSyCAog6e97iRtgeJevBVWIsrSE2vcHz58iI" // Mesma do React Native
      print("⚠️ Usando API Key de fallback (mesma do React Native)")
    }
    
    // Inicializar Google Maps
    if let key = apiKey {
      GMSServices.provideAPIKey(key)
      print("🗺️ Google Maps inicializado com sucesso!")
    } else {
      print("💥 ERRO CRÍTICO: Não foi possível obter API Key")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
