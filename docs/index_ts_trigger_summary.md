# `functions/src/index.ts` trigger összefoglaló

Ez a dokumentum mostantól csak rövid átvezető. A részletes, egységesített leírás itt található:

- `docs/notification_and_group_flow_summary.md`

## Röviden

Az `index.ts` jelenleg egy közös FCM helperre épül, és több Firestore create triggert exportál:

- `onNoteCreated`
- `onContactCreated`
- `onDocumentCreatedNotification`
- `onCalendarEventCreated`
- `onTodoCreated`

Mindegyik ugyanazt a `groupId` topicot használja, és `notification` + `data` payloadot küld.

## Mire figyelj?

- csak új dokumentum létrejöttekor futnak,
- update-re nem reagálnak,
- a kliens oldali navigáció a `data.target` mezőből dolgozik.

## Kapcsolódó fő dokumentum

- `docs/notification_and_group_flow_summary.md`

