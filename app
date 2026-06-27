from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

# -----------------------------
# 1. REDDIT DATA
# -----------------------------
def get_posts():
    url = "https://www.reddit.com/r/Entrepreneur+startups+freelance+smallbusiness/top.json?limit=20&t=week"
    headers = {"User-Agent": "StartupForgeAI"}

    try:
        r = requests.get(url, headers=headers, timeout=10)
        data = r.json()

        posts = []
        for p in data["data"]["children"]:
            posts.append(p["data"]["title"])

        return posts

    except Exception as e:
        return [f"Error fetching data: {str(e)}"]


# -----------------------------
# 2. SIMPLE IDEA ENGINE
# -----------------------------
def build_ideas(posts):

    ideas = []

    for post in posts:

        text = post.lower()

        score = 0
        if "need" in text:
            score += 30
        if "can't" in text:
            score += 25
        if "struggle" in text:
            score += 20
        if "problem" in text:
            score += 15
        if "how" in text:
            score += 10

        if score == 0:
            continue

        ideas.append({
            "problem": post,
            "app_idea": "AI Solution App",
            "demand_score": score,
            "profit_potential": score + 10
        })

    return sorted(ideas, key=lambda x: x["demand_score"], reverse=True)


# -----------------------------
# 3. API ROUTES
# -----------------------------
@app.route("/")
def home():
    return {
        "status": "StartupForge AI running",
        "version": "MVP v1",
        "usage": "/generate"
    }


@app.route("/generate")
def generate():

    posts = get_posts()
    ideas = build_ideas(posts)

    return jsonify({
        "posts_analyzed": len(posts),
        "ideas_found": len(ideas),
        "top_ideas": ideas[:10]
    })


# -----------------------------
# 4. RENDER COMPATIBLE RUN
# -----------------------------
if __name__ == "__main__":

    port = int(os.environ.get("PORT", 10000))

    app.run(host="0.0.0.0", port=port)
