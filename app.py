from flask import Flask, render_template, request, jsonify
import google.generativeai as genai
import os

app = Flask(__name__)

# Configure the Gemini API
# gemini_api_key = os.getenv("GEMINI_API_KEY")
# if not gemini_api_key:
#     raise ValueError("No GEMINI_API_KEY set for Flask application")
# genai.configure(api_key=gemini_api_key)               
# model = genai.GenerativeModel('gemini-2.5-flash')


genai.configure(api_key='AIzaSyAuXbTLHgEpVXj_CgTTIjy5ead3PDL9S5c')               
model = genai.GenerativeModel('gemini-2.5-flash')




try:
    with open('business_context.txt', 'r', encoding='utf-8') as f:
        BUSINESS_CONTEXT = f.read()
except FileNotFoundError:
    # Provide a fallback context in case the file is missing
    print("WARNING: business_context.txt not found. Using a default fallback context.")
    BUSINESS_CONTEXT = "You are a helpful assistant."




@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    user_message = request.json.get('message')
    try:
        prompt = f"{BUSINESS_CONTEXT}\n\nCustomer: {user_message}\nBrewBot:"
        response = model.generate_content(prompt)
        
        bot_response_text = response.text

     
        if user_message.lower() == 'hello':
            # Ensure the tag isn't already there, then add it.
            if '[quick_replies:' not in bot_response_text:
                bot_response_text += " [quick_replies:Show Menu|Special Offers|Location & Hours]"

        return jsonify({'response': bot_response_text})

    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({'error': str(e)})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
