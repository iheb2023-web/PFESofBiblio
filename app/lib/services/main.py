from flask import Flask, request, jsonify
from langchain_community.agent_toolkits.sql.toolkit import SQLDatabaseToolkit
from langchain_community.utilities import SQLDatabase
from langchain_community.llms import OpenAI
from langchain_google_genai import GoogleGenerativeAI  
from langchain.agents import initialize_agent  

import os

app = Flask(__name__)
#AIzaSyALbVJW9lf4zi5NMkAWOFusTq7YMdy03ME
#AIzaSyB-tPq1oFJFmLkLgt5Baf6prtGZyyJzA3E

os.environ["GOOGLE_API_KEY"] = "AIzaSyALbVJW9lf4zi5NMkAWOFusTq7YMdy03ME"
db = SQLDatabase.from_uri("mysql+pymysql://root@localhost/sofbiblio_db")
llm = GoogleGenerativeAI(model="gemini-1.5-flash", temperature=0)
toolkit = SQLDatabaseToolkit(llm=llm, db=db)
agent = initialize_agent(
    tools=toolkit.get_tools(),
    llm=llm,
   agent="zero-shot-react-description",
    verbose=True
)
@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    prompt = data.get("prompt")
    try:
        response = agent.run(prompt)
        return jsonify({"response": response})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)



