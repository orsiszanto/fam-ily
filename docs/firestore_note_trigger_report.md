# Firestore note-trigger report

Ez a dokumentum mostantól csak rövid átvezető. A részletes, egységesített leírás itt található:

- `docs/notification_and_group_flow_summary.md`

## Röviden

A note-trigger alapvetően helyes:

- a Firestore útvonal egyezik,
- a trigger `onDocumentCreated`-et használ,
- a note létrehozás `add()`-dal történik,
- a `groupId` ugyanaz a közös azonosító, mint a topic neve.

## Mire figyelj?

- csak új létrehozásra fut,
- update-re nem,
- a kézbesítéshez kell a topic-feliratkozás és a sikeres FCM send.

## Kapcsolódó fő dokumentum

- `docs/notification_and_group_flow_summary.md`

