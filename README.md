# image_reader

This Flutter application showcases the integration of Google's ML Kit for Optical Character Recognition (OCR) to perform two primary functions: converting image-based text into editable text and extracting email addresses from images. The app utilizes the `google_ml_kit` package to access powerful text recognition capabilities, allowing it to identify and process text contained within images selected from the device's gallery.

The core functionality is divided into two main features:
1. **Image to Text Conversion:** This feature enables users to select an image, after which the app uses OCR technology to recognize and display all text found in the image. It's particularly useful for digitizing printed documents or transcribing notes from photos.
   
2. **Extract Emails:** This specialized feature scans the selected image for text that matches the pattern of email addresses. It then extracts and displays these email addresses separately. This can be incredibly useful for gathering contact information from business cards, flyers, or any printed material.

Additionally, the app includes a "Clear Text" button, allowing users to reset the output field and perform multiple recognitions without restarting the app. This makes the app versatile for repeated use in various scenarios, from business networking to personal document management.

Designed with simplicity in mind, this application demonstrates the practical application of OCR in mobile development, providing a foundation for developers interested in exploring text recognition and its potential uses in Flutter projects.
