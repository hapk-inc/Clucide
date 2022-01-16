package inc.hapk.traccia

import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterActivity
//import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory

//import com.google.firebase.FirebaseApp
//import com.google.firebase.appcheck.FirebaseAppCheck


class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        /*if(BuildConfig.DEBUG){
            FirebaseApp.initializeApp( *//*context=*//*this)
            val firebaseAppCheck: FirebaseAppCheck = FirebaseAppCheck.getInstance()
            firebaseAppCheck.installAppCheckProviderFactory(
                DebugAppCheckProviderFactory.getInstance()
            )
        }*/
    }
}
