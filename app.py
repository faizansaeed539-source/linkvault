from flask import Flask, request, redirect, render_template, abort
import psycopg2
import random
import string
import os

app = Flask(__name__)


def get_db():
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "linkvault"),
        user=os.getenv("DB_USER", "linkvault_user"),
        password=os.getenv("DB_PASS", "devpassword")
    )
    return conn


def generate_code(length=6):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choices(chars, k=length))


@app.route("/")
def index():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT short_code, original_url, clicks FROM links ORDER BY created_at DESC")
    links = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("index.html", links=links)


@app.route("/shorten", methods=["POST"])
def shorten():
    original_url = request.form.get("url")
    if not original_url:
        abort(400)
    short_code = generate_code()
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO links (short_code, original_url, clicks) VALUES (%s, %s, 0)",
        (short_code, original_url)
    )
    conn.commit()
    cur.close()
    conn.close()
    return redirect("/")


@app.route("/<short_code>")
def redirect_link(short_code):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "UPDATE links SET clicks = clicks + 1 WHERE short_code = %s RETURNING original_url",
        (short_code,)
    )
    result = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    if result is None:
        abort(404)
    return redirect(result[0])


@app.route("/health")
def health():
    return {"status": "ok"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
