# Notification és group flow összefoglaló

## Cél

Ez a dokumentum a teljes értesítési láncot foglalja össze egy helyen:

- a `groupId` betöltését,
- a Firestore create triggerek működését,
- az FCM topic alapú küldést,
- valamint a kliens oldali navigációt az értesítésre kattintva.

Ez a kanonikus változat; a korábbi, részletesebb dokumentumok ide mutatnak vissza.

---

## Rövid konklúzió

A végső működési lánc így áll össze:

1. a felhasználó belép,
2. az app betölti a felhasználóhoz tartozó `groupId`-t,
3. a készülék feliratkozik a megfelelő FCM topicra,
4. új Firestore dokumentum létrejöttekor a trigger lefut,
5. a backend elküldi az értesítést a csoport topicjára,
6. a kliens oldali tap-kezelés a payload alapján megnyitja a megfelelő oldalt.

---

## 1) A `groupId` szerepe a teljes flow-ban

A `groupId` a rendszer központi azonosítója:

- a Firestore útvonalak ezt használják,
- az FCM topic neve is ez,
- a kliens oldali navigáció is erre épül.

### Hol jelenik meg a kódban?

- `lib/services/user_service.dart`
- `lib/services/userSubscription_service.dart`
- `lib/pages/dashboard/dashboard.dart`

### Mi a célja?

Az appnak ugyanazt az azonosítót kell használnia minden rétegben, különben a note létrejönhet ugyan, de az értesítés nem a megfelelő csoportra megy, vagy a kattintás rossz oldalra navigál.

---

## 2) Backend trigger logika az `index.ts`-ben

A Cloud Functions belépési pontja: `functions/src/index.ts`.

### Közös helper

A fájlban van egy közös küldő segédfüggvény:

- `sendGroupNotification(topic, title, body, data)`

Ez intézi az FCM üzenet küldését:

- a `topic` a csoport azonosítója,
- a `notification` rész adja a címet és az üzenetet,
- a `data` rész a kliens oldali navigációhoz kell.

### Miért jó ez a megoldás?

- kevesebb ismétlés van a kódban,
- minden trigger ugyanazt a payload-sémát használja,
- könnyebb új funkciókat hozzáadni.

---

## 3) A jelenlegi triggerek listája

Az `index.ts` jelenleg ezeket az `onDocumentCreated` triggert exportálja:

| Trigger neve | Firestore útvonal | `target` |
| --- | --- | --- |
| `onNoteCreated` | `group/{groupId}/notes/{noteId}` | `notes` |
| `onContactCreated` | `group/{groupId}/contacts/{contactId}` | `contacts` |
| `onDocumentCreatedNotification` | `group/{groupId}/documents/{documentId}` | `documents` |
| `onCalendarEventCreated` | `group/{groupId}/calendarEvents/{eventId}` | `calendar` |
| `onTodoCreated` | `group/{groupId}/todoLists/{todoListId}` | `todoLists` |

### Közös szabály mindegyiknél

- csak új dokumentum létrejöttekor futnak,
- update-re nem reagálnak,
- a `groupId` topicra küldenek.

---

## 4) A note trigger részletes működése

### Firestore útvonal

- Flutter oldalon a jegyzetek ide kerülnek: `group/{groupId}/notes`
- a trigger erre figyel: `group/{groupId}/notes/{noteId}`

Ez azt jelenti, hogy a note létrehozás és a trigger útvonala egyezik.

### Mi történik létrehozáskor?

1. a dokumentum létrejön a Firestore-ban,
2. a trigger megkapja az adatokat,
3. kiolvassa a `groupId`-t a path-ból,
4. elküldi az FCM üzenetet a megfelelő topicra,
5. az üzenet tartalmazza a navigációhoz szükséges `data` mezőt is.

### A note payloadja

- `notification.title`: `New note!`
- `notification.body`: a note `title` mezője, vagy `New note created`
- `data.target`: `notes`
- `data.groupId`
- `data.noteId`

---

## 5) Miért fontos a `data.target`?

Az értesítésre kattintva a kliensnek tudnia kell, melyik képernyőt nyissa meg.

A `target` alapján megkülönböztethető:

- `notes`
- `contacts`
- `documents`
- `calendar`
- `todoLists`

Ezért nem elég csak a `notification` rész; a `data` rész nélkül a kliens nem tudna megbízhatóan route-olni.

---

## 6) Kliens oldali feliratkozás és azonnali szinkron

A kliens oldali feliratkozás a `UserSubscriptionService`-hez kapcsolódik, és a belépés után aktiválódik.

### Mi a cél?

- a készülék feliratkozzon a megfelelő topicra,
- még a felhasználói műveletek előtt legyen kész az értesítési infrastruktúra,
- ne maradjon ki az első néhány esemény.

### Fontos szempont

A subscription flow nem blokkolhatja a teljes UI-t. A Dashboardnak akkor is működnie kell, ha a háttérben a topic feliratkozás éppen késik vagy hibát dob.

---

## 7) Értesítésre kattintás és navigáció

A kliens oldalon az értesítés tap kezelésének célja, hogy a felhasználó a megfelelő oldalra jusson.

### A működés lényege

- a tap eseményből kiolvassuk a payloadot,
- megnézzük a `target` értékét,
- a `groupId` alapján megnyitjuk a megfelelő oldalt.

### Miért kell ez külön kezelésként?

Mert notification callbackből nem mindig érhető el widget context, ezért a navigáció nem támaszkodhat sima `Navigator.push(context, ...)` megoldásra.

---

## 8) Ismert korlátok és kockázatok

### Csak create trigger van

Az aktuális Cloud Function-ok `onDocumentCreated` alapúak, tehát:

- új dokumentumnál igen,
- update-nél nem,
- delete-nél nem.

Ha később módosításra vagy törlésre is kell értesítés, külön update/delete trigger szükséges.

### A kézbesítéshez kell a topic feliratkozás

Az értesítés akkor ér célba, ha:

- a kliens tényleg feliratkozott a helyes topicra,
- a Cloud Function lefutott,
- az FCM küldés sikeres volt.

### Hibaelhárítás

Ha az értesítés nem érkezik meg, ellenőrizni kell:

- létrejött-e a dokumentum a megfelelő útvonalon,
- a user feliratkozott-e a topicra,
- futott-e a Cloud Function,
- a deployolt function biztosan az aktuális forrásból készült-e.

---

## 9) Végső megoldás összefoglalása

A mostani megoldás lényege:

- a Firestore és a Cloud Function útvonalak egyeznek,
- több, egységes mintára épülő trigger van,
- minden trigger ugyanarra a `groupId` topicra küld,
- a payload tartalmazza a navigációhoz szükséges adatokat,
- a kliens oldalon a tap handler meg tudja nyitni a megfelelő oldalt.

Ez együtt adja azt a végső flow-t, hogy egy új elem létrehozása után az értesítés megérkezik, és kattintásra a helyes képernyő nyílik meg.

---

## 10) Kapcsolódó fájlok

- `functions/src/index.ts`
- `lib/main.dart`
- `lib/pages/dashboard/dashboard.dart`
- `lib/services/userSubscription_service.dart`
- `lib/services/notification_service.dart`
- `docs/index_ts_trigger_summary.md`
- `docs/firestore_note_trigger_report.md`


