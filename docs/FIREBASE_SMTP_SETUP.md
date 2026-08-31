# Firebase SMTP Setup Guide for CQAAG Mobile App & Web

This guide provides step-by-step instructions on how to configure **Firebase** to send email verification links, password resets, and member notifications through **Gmail SMTP** (`cqaag.gh@gmail.com`).

---

## 🔑 Your Gmail SMTP Credentials

| Parameter | Value |
| :--- | :--- |
| **Email Address** | `cqaag.gh@gmail.com` |
| **Sender Name** | `CQAAG Secretariat` |
| **SMTP Host** | `smtp.gmail.com` |
| **SMTP Port** | `465` (SSL) or `587` (TLS) |
| **SMTP Username** | `cqaag.gh@gmail.com` |
| **Google App Password** | `ephm rhlg kgtf vwhd` |

---

## 🛠️ Method 1: Firebase Authentication Email Templates (Instant & Recommended)

This configures Firebase Auth's default verification and password reset emails to display as coming from the CQAAG Secretariat.

1. Open the **[Firebase Console](https://console.firebase.google.com/)** and select the **CQAAG** project.
2. In the left sidebar, click **Build** $\rightarrow$ **Authentication**.
3. Click on the **Templates** tab at the top.
4. For each template (**Email address verification**, **Password reset**, **Email address change**):
   - Click the **Edit (pencil ✏️)** icon.
   - **Sender name**: Change to `CQAAG Secretariat`.
   - **Reply-to**: Set to `cqaag.gh@gmail.com`.
   - Click **Save**.

---

## 🚀 Method 2: Firebase Extension — "Trigger Email from Firestore" (Full SMTP Delivery)

If you want custom emails, verification codes, or PDF inspection attachments to be dispatched directly through your Gmail SMTP server:

### Step 1: Install the Extension in Firebase
1. Go to the [Firebase Extensions Hub](https://extensions.dev/extensions/firebase/firestore-send-email).
2. Click **Install in Firebase console** and select your CQAAG project.

### Step 2: Configure Extension Parameters
When prompted for configuration values, enter:

- **SMTP connection URI**:
  ```text
  smtps://cqaag.gh%40gmail.com:ephmrhlgkgtfvwhd@smtp.gmail.com:465
  ```
  *(Note: `%40` is the URL-encoded `@` symbol in the email username, and spaces are removed from the App Password).*

- **Default FROM address**:
  ```text
  cqaag.gh@gmail.com
  ```

- **Default SENDER name**:
  ```text
  CQAAG Secretariat
  ```

- **Default REPLY-TO address**:
  ```text
  cqaag.gh@gmail.com
  ```

- **Email documents collection**:
  ```text
  mail
  ```

### Step 3: Send an Email from Flutter or Web
To send any email using this SMTP pipeline, simply add a document to the `mail` collection in Cloud Firestore:

```dart
// In Flutter / Dart:
await FirebaseFirestore.instance.collection('mail').add({
  'to': 'recipient@example.com',
  'message': {
    'subject': 'CQAAG Official Notification',
    'text': 'Hello! Your membership details have been verified.',
    'html': '<h2>CQAAG Official Notification</h2><p>Hello! Your membership details have been verified.</p>',
  },
});
```
Firebase will automatically pick up this document, send it via your Gmail SMTP, and update the document with delivery status: `{ state: "SUCCESS" }`.

---

## ⚡ Method 3: Cloud Function with Nodemailer (Alternative Free Setup)

If you use Firebase Cloud Functions:

1. In your `functions/` directory, install Nodemailer:
   ```bash
   npm install nodemailer
   ```

2. Add the transport configuration in `functions/index.js`:
   ```javascript
   const functions = require("firebase-functions");
   const nodemailer = require("nodemailer");

   const transporter = nodemailer.createTransport({
     service: "gmail",
     auth: {
       user: "cqaag.gh@gmail.com",
       pass: "ephmrhlgkgtfvwhd"
     }
   });

   exports.sendCustomEmail = functions.https.onCall(async (data, context) => {
     const mailOptions = {
       from: '"CQAAG Secretariat" <cqaag.gh@gmail.com>',
       to: data.to,
       subject: data.subject,
       html: data.html
     };

     return transporter.sendMail(mailOptions);
   });
   ```

---

## 🔒 Security Best Practice
- **Never commit active App Passwords to public Git repositories.**
- Store SMTP credentials in `.env` (which is ignored by Git in `.gitignore`) or in Google Cloud Secret Manager / Firebase Environment Config.
