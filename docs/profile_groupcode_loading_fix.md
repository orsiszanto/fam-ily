# ProfilePage group code loading fix

## Mi volt a probléma?

A `Group code` ablak néha csak `Loading...` szöveget mutatott, vagy úgy tűnt, mintha beragadt volna.

## Mi okozta?

A `ProfilePage` korábban nem kérte le külön a felhasználói adatokat, mielőtt a dialog megpróbálta volna kiolvasni a csoportkódot.

A kód csak ezeket a state-eket tudta használni:
- `UserInfoLoaded`
- `UserInfoUpdated`

Ha ezek még nem érkeztek meg, akkor a dialog üres maradt, és a fallback szöveg `Loading...` volt.

## Mi változott?

A javítás a `lib/pages/user/profile_page.dart` fájlba került.

### Fő módosítások
- a page megnyitásakor egyszer lefut a `loadUserInfo()`
- ezt a `didChangeDependencies()` indítja el
- `addPostFrameCallback` biztosítja, hogy a lekérés a frame után fusson le
- a `_didRequestUserInfo` védi a többszöri betöltéstől
- a dialog már a `UserError` állapotot is kezeli

## Miért működik most?

Most a `ProfilePage` maga is elindítja a user info betöltését, ezért:

1. a bloc megkapja a felhasználói adatokat,
2. a `groupCode` bekerül a `UserInfoLoaded` vagy `UserInfoUpdated` state-be,
3. a dialog már ezt az értéket tudja megjeleníteni,
4. így a csoportkód nem marad `Loading...` állapotban.

## Röviden

### Korábban
- a dialog azonnal nyílt
- de a user info nem volt mindig betöltve
- ezért a csoportkód nem jelent meg biztosan

### Most
- a page megnyitásakor indul a betöltés
- a csoportkód elérhető lesz a dialog számára
- a megjelenítés stabilabb és kiszámíthatóbb

## Érintett fájl

- `lib/pages/user/profile_page.dart`

