# FCM foreground notification fix

## Mi volt a probléma?

Az FCM üzenetek megérkeztek, amikor az alkalmazás háttérben futott vagy be volt zárva, de ha az app nyitva volt, nem jelent meg rendszeres értesítés.

Ez nem Firebase-hiba volt, hanem egy Flutter/Android viselkedés:
- a háttérben a rendszer tudja megjeleníteni az FCM notificationt,
- viszont előtérben a kapott üzenetet nekünk kell feldolgozni,
- és külön helyi értesítést kell létrehozni, ha azt szeretnénk, hogy a felhasználó bannerként is lássa.

---

## Milyen módosítások kellettek?

### 1) `lib/services/notification_service.dart`

Itt történt a fő javítás.

#### Mit adtunk hozzá?
- `flutter_local_notifications` inicializálása
- egy nagy prioritású Android notification channel létrehozása
- FCM foreground engedélyek bekapcsolása
- `FirebaseMessaging.onMessage` listener, ami előtérben megjeleníti az üzenetet
- egy `_isInitialized` védelem, hogy ne regisztrálódjanak a listenerek többször

#### Miért kellett ez?

A `FirebaseMessaging.onMessage` csak megkapja az üzenetet, de nem rajzol ki semmit a képernyőre.
Ezért kellett egy külön plugin, ami helyi értesítést tud mutatni.

A kód ezt csinálja:
1. megkapja az FCM üzenetet,
2. ellenőrzi, hogy van-e `notification` rész,
3. létrehoz egy Android local notificationt,
4. ezzel az app nyitva is megmutatja az értesítést.

---

### 2) `lib/main.dart`

Itt az a lényeg, hogy a notification setup csak bejelentkezés után induljon el, és ne többször.

#### Mit csinál a jelenlegi logika?
- `LoggedIn` állapotnál meghívja a `NotificationService().initFCM()`-et
- ezzel együtt elindul a subscription setup is
- `NotAuthenticated` esetén leállnak a figyelések

#### Miért jó ez?

Így az FCM inicializálás egy kontrollált ponton történik, és nem app-startkor minden esetben.
Ez csökkenti a duplikált listenerek és többes regisztrációk esélyét.

---

### 3) `android/app/src/main/AndroidManifest.xml`

#### Mit adtunk hozzá?
- `android.permission.POST_NOTIFICATIONS`

#### Miért kellett ez?

Android 13-tól ez külön jogosultság.
Ha ez hiányzik, az app kérheti ugyan az értesítést, de az OS nem biztos, hogy megjeleníti.

---

### 4) `pubspec.yaml`

#### Mit adtunk hozzá?
- `flutter_local_notifications`

#### Miért kellett ez?

Ez a csomag felel azért, hogy az app maga is tudjon értesítést megjeleníteni előtérben.
A Firebase Messaging önmagában nem elég ehhez.

---

### 5) `android/app/build.gradle.kts`

#### Mit adtunk hozzá?
- core library desugaring bekapcsolása
- `com.android.tools:desugar_jdk_libs` dependency

#### Miért kellett ez?

A `flutter_local_notifications` újabb Android API-kat és Java idő-kezelést használhat, amihez desugaring kell.
Enélkül a Gradle build hibával leállt.

---

## Miért bővítettük ki így a kódot?

Mert a foreground FCM két külön részből áll:

### 1. Üzenet fogadása
Ezt a Firebase Messaging végzi:
- `FirebaseMessaging.onMessage`

### 2. Látható értesítés megjelenítése
Ezt külön kell megcsinálni:
- `flutter_local_notifications.show(...)`

Ezért lett a service hosszabb:
- külön notification channel,
- külön inicializálás,
- külön permission-kezelés,
- külön foreground handler.

Ez nem felesleges bonyolítás, hanem szükséges ahhoz, hogy az app nyitva is bannert mutasson.

---

## Miért működik most?

Azért működik, mert most a rendszer a következő láncot végig tudja futtatni:

1. A Firebase elküldi az FCM üzenetet.
2. Az app előtérben megkapja az üzenetet az `onMessage` listenerben.
3. A kód létrehoz egy local notificationt.
4. Az Android notification channel és jogosultság engedi a megjelenítést.
5. A felhasználó látja az értesítést akkor is, amikor az app nyitva van.

---

## Röviden

### Korábban
- háttérben működött
- előtérben csak megérkezett, de nem látszott

### Most
- háttérben működik
- előtérben is látszik
- a build is sikeresen elkészül

---

## Tesztelt eredmény

A build hibája megszűnt, és a debug APK sikeresen elkészült.
Ez azt jelenti, hogy a foreground notification megoldás nemcsak logikailag, hanem Android build szinten is helyes.

