import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:renbo/utils/constants.dart';

/// A data class to hold the structured response from the Gemini API.
class GeminiClassifiedResponse {
  final bool isHarmful;
  final String response;

  GeminiClassifiedResponse({
    this.isHarmful = false,
    this.response = "Sorry, I couldn't connect. Please try again.",
  });
}

class GeminiService {
  final String _apiKey = AppConstants.geminiApiKey;
  final String _modelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=';

  /// *FIX*: Defines the 'generateAndClassify' method to match what is called in chat_screen.dart
  Future<GeminiClassifiedResponse> generateAndClassify(String prompt) async {
    final headers = {'Content-Type': 'application/json'};

    // This single prompt instructs the model to perform both tasks
    // and return a structured JSON object.
    final systemPrompt = """
You are Renbot, a supportive and non-judgmental AI assistant. Your role is to provide a safe space for users to express their thoughts and feelings. First, create an empathetic and supportive response to the user's message. Second, classify the user's message for self-harm or suicidal ideation.
** always be empathetic and supportive in your response. **
** always be calm, neutral, and non-judgmental. **
** listen and validate the user's feelings. **
** donot give a long reply , keep it simple and crisp **
*Your core principles:*
- *Listen Empathetically:* Acknowledge the user's feelings and perspectives.
- *Be Neutral and Calm:* Use a calm, measured, and conversational tone. Be professional and cool.
- *Offer Support:* Provide encouragement and validation.
- *Avoid Overly Passionate Language:* Use simple, direct language. Avoid excessive emojis or exclamation points.
- *Disclaimers:* You are not a human therapist and cannot give medical or diagnostic advice. Only state this when the user's message is directly related to a medical or clinical topic.
- *Language support:* If the user talks to you in a regional indian language reply to them using the same.
- *Concluding the talk:* If the conversation is leading to conclusion, give them support and tend towards conclusion.
You MUST respond in a valid JSON format that follows this exact schema:
{
  "type": "OBJECT",
  "properties": {
    "isHarmful": { "type": "BOOLEAN" },
    "response": { "type": "STRING" }
  }
}

- "isHarmful": Set to 'true' if the user's message contains any indication of self-harm, suicide, or immediate danger. Otherwise, set to 'false'.
- "response": This field must contain your complete, empathetic, and supportive message based on your core principles (calm, neutral, supportive, non-judgmental).

User's message: "$prompt"
""";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": systemPrompt}
          ]
        }
      ],
      // We explicitly ask for a JSON response.
      "generationConfig": {
        "responseMimeType": "application/json",
      }
    });

    try {
      final response = await http.post(
        Uri.parse('$_modelUrl$_apiKey'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The model's response is a JSON string that we need to parse again.
        final jsonString = data['candidates'][0]['content']['parts'][0]['text'];
        final classifiedData = jsonDecode(jsonString);

        return GeminiClassifiedResponse(
          isHarmful: classifiedData['isHarmful'] ?? false,
          response: classifiedData['response'] ??
              "I'm having trouble understanding right now. Could we talk about something else?",
        );
      } else {
        // Return a default "safe" response in case of API errors.
        return GeminiClassifiedResponse();
      }
    } catch (e) {
      // Return a default "safe" response for network or parsing errors.
      return GeminiClassifiedResponse(
          response:
              "Something went wrong. Please check your internet connection. 😞");
    }
  }
}
