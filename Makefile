# rule to lazily clone gyp
./deps/gyp:
	git clone --depth 1 https://chromium.googlesource.com/external/gyp.git ./deps/gyp

# we specify a root target for android to prevent all of the targets from spidering out
GypAndroid.mk: ./deps/gyp example/libtextsort.gyp support-lib/support_lib.gyp example/example.djinni
	./example/run_djinni.sh
	ANDROID_BUILD_TOP=dirname $(which ndk-build) deps/gyp/gyp --depth=. -f android -DOS=android -Icommon.gypi example/libtextsort.gyp --root-target=libtextsort_jni

# this target implicitly depends on GypAndroid.mk since gradle will try to make it
example_android: GypAndroid.mk
	cd example/android/ && ./gradlew app:assembleDebug
	@echo "Apks produced at:"
	@python example/glob.py example/ '*.apk'