package xyz.violet.communitydownloader

import androidx.annotation.NonNull
//import com.github.kilianB.hash.Hash
//import com.github.kilianB.hashAlgorithms.AverageHash
//import com.github.kilianB.hashAlgorithms.HashingAlgorithm
//import com.github.kilianB.hashAlgorithms.PerceptiveHash
//import com.github.kilianB.matcher.exotic.SingleImageMatcher
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
//import java.io.File


class MainActivity: FlutterActivity() {
    private val NATIVELIBDIR_CHANNEL = "xyz.violet.communitydownloader/nativelibdir";
//    private val hashMap:HashMap<String,Hash> = HashMap<String,Hash>();

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVELIBDIR_CHANNEL).setMethodCallHandler {
            call, result ->
            // Note: this method is invoked on the main thread.
            // TODO
            if (call.method == "getNativeDir") {
                result.success(getApplicationContext().getApplicationInfo().nativeLibraryDir);
            }
//            if (call.method == "calHash") {
//                val arg = call.argument<String>("filename");
//                val img = File(arg);
//                val hasher: HashingAlgorithm = PerceptiveHash(32);
//                val hash: Hash = hasher.hash(img);
//
////                hash.
//                hashMap.put(arg.toString(), hash);
//            }
            result.notImplemented()
        }

//        val img0 = File("path/to/file.png")
//        val img1 = File("path/to/secondFile.jpg")
//
//        val hasher: HashingAlgorithm = PerceptiveHash(32)
//
//        val hash0: Hash = hasher.hash(img0)
//        val hash1: Hash = hasher.hash(img1)
//
//        val similarityScore = hash0.normalizedHammingDistance(hash1)
//        hash0.
//
//        if (similarityScore < .2) {
//            //Considered a duplicate in this particular case
//        }
//
//        val matcher = SingleImageMatcher()
//        matcher.addHashingAlgorithm(AverageHash(64), .3)
//        matcher.addHashingAlgorithm(PerceptiveHash(32), .2)
//
//        if (matcher.checkSimilarity(img0, img1)) {
//            //Considered a duplicate in this particular case
//        }
    }
}
