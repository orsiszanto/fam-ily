/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

async function sendGroupNotification(
    topic: string,
    title: string,
    body: string,
    data: Record<string, string>,
) {
    await admin.messaging().send({
      topic,
      notification: {
        title,
        body,
      },
      data,
    });
}

export const onNoteCreated = onDocumentCreated(
    "group/{groupId}/notes/{noteId}",
    async (event) => {
        const data = event.data?.data();
        const groupId = event.params.groupId;

        if (!data) {
            return;
        }

        await sendGroupNotification(groupId, "New note!", data.title ?? "New note created", {});
    }
);

export const onContactCreated = onDocumentCreated(
    "group/{groupId}/contacts/{contactId}",
    async (event) => {
        const data = event.data?.data();
        const groupId = event.params.groupId;

        if (!data) {
            return;
        }

        await sendGroupNotification(groupId, "New contact!", data.name ?? "New contact created", {});
    }
);

export const onDocumentCreatedNotification = onDocumentCreated(
    "group/{groupId}/documents/{documentId}",
    async (event) => {
        const data = event.data?.data();
        const groupId = event.params.groupId;

        if (!data) {
            return;
        }

        await sendGroupNotification(
            groupId,
            "New document!",
            data.fileName ?? "New document uploaded",
            {},
        );
    }
);

export const onCalendarEventCreated = onDocumentCreated(
    "group/{groupId}/calendarEvents/{eventId}",
    async (event) => {
        const data = event.data?.data();
        const groupId = event.params.groupId;

        if (!data) {
            return;
        }

        await sendGroupNotification(
            groupId,
            "New calendar event!",
            data.title ?? "New calendar event created",
            {},
        );
    }
);

export const onTodoCreated = onDocumentCreated(
    "group/{groupId}/todoLists/{todoListId}",
    async (event) => {
        const data = event.data?.data();
        const groupId = event.params.groupId;

        if (!data) {
            return;
        }

        await sendGroupNotification(
            groupId,
            "New todo list!",
            data.title ?? "New todo list created",
            {},
        );
    }
);