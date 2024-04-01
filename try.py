import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
import re
import string
import streamlit as st
import requests
from bs4 import BeautifulSoup
import concurrent.futures
import time

# Load the datasets
dataframe_true = pd.read_csv("Real.csv")
dataframe_fake = pd.read_csv("Fake.csv")

# Drop unnecessary columns
dataframe_true = dataframe_true.drop(columns=['publish_date', 'headline_category'])
dataframe_fake = dataframe_fake.drop(columns=['label'])

# Add a 'class' column to indicate fake news (0) and true news (1)
dataframe_fake["class"] = 0
dataframe_true["class"] = 1

# Concatenate the datasets
dataframe_merge = pd.concat([dataframe_fake, dataframe_true], axis=0)

# Preprocessing function
def preprocess_text(text):
    if isinstance(text, str):  
        text = text.lower()
        text = re.sub('\[.*?\]', '', text)
        text = re.sub("\\W", " ", text)
        text = re.sub('https?://\S+|www\.\S+', '', text)
        text = re.sub('<.*?>+', '', text)
        text = re.sub('[%s]' % re.escape(string.punctuation), '', text)
        text = re.sub('\n', '', text)
        text = re.sub('\w*\d\w*', '', text)
        return text
    else:
        return ""  

# Apply preprocessing to the text column
dataframe_merge["text"] = dataframe_merge["text"].apply(preprocess_text)

# Split the data into features (X) and target (y)
X = dataframe_merge["text"]
y = dataframe_merge["class"]

# Vectorize the text data
vectorizer = TfidfVectorizer()
X_vectorized = vectorizer.fit_transform(X)

# Train Logistic Regression model
lr_model = LogisticRegression()
lr_model.fit(X_vectorized, y)

# Train Decision Tree model
dt_model = DecisionTreeClassifier()
dt_model.fit(X_vectorized, y)

# Function to detect fake news using ML
def detect_fake_news(news):
    def output_label(n):
        if n == 0:
            return "Fake News"
        elif n == 1:
            return "Not Fake News"

    news = preprocess_text(news)
    news_vectorized = vectorizer.transform([news])
    lr_prediction = lr_model.predict(news_vectorized)
    dt_prediction = dt_model.predict(news_vectorized)
    
    if lr_prediction[0] == dt_prediction[0]:
        return output_label(lr_prediction[0])
    else:
        return "Not Fake News"

# Function to extract text content from a given URL with timeout and retry mechanism
def extract_text_from_url(url):
    max_retries = 3
    retry_delay = 1
    for _ in range(max_retries):
        try:
            response = requests.get(url, timeout=10)  
            if response.status_code == 200:
                soup = BeautifulSoup(response.content, 'html.parser')
                text = " ".join([p.text for p in soup.find_all('p')])
                return text
        except Exception as e:
            st.error(f"Error extracting text from {url}: {e}")
            time.sleep(retry_delay)
    return None

# Function to extract keywords from text
def extract_keywords(text):
    words = re.findall(r'\b\w+\b', text.lower())
    stop_words = set([
        "i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves",
        "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their",
        "theirs", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was",
        "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", "an", "the", "and",
        "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between",
        "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off",
        "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any",
        "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so",
        "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now"
    ])
    keywords = [word for word in words if word not in stop_words and len(word) > 2]
    return keywords

# Function to check if keywords exist in the provided text
def check_keywords_in_text(text, keywords):
    found_keywords = [keyword for keyword in keywords if keyword in text.lower()]
    return found_keywords

# Streamlit app for Web Extraction page
def web_extraction_page():
    st.title("Fake News Detection using Web Extraction")
    st.write("Enter the news text ")

    news_channels = {
        "NDTV": "https://www.ndtv.com/",
        "India Today": "https://www.indiatoday.in/",
        "Times of India": "https://timesofindia.indiatimes.com/",
        "Indian Express": "https://indianexpress.com/",
        "Hindustan Times": "https://www.hindustantimes.com/",
        "The Hindu": "https://www.thehindu.com/news/national/",
        "News18": "https://www.news18.com/",
        "Zee news": "https://zeenews.india.com/",
        "BBC":"https://www.bbc.com/news/world",
        "DD":"https://ddnews.gov.in/en/",
        "Mirror":"https://www.timesnownews.com/mirror-now",
        "Times now":"https://www.timesnownews.com/live-tv/mirror-now"
    }

    input_text = st.text_area("Enter the news text:", "")  
    if st.button("Check Fake News"):
        if input_text:
            with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
                future_to_channel = {executor.submit(extract_text_from_url, url): channel for channel, url in news_channels.items()}
                for future in concurrent.futures.as_completed(future_to_channel):
                    channel = future_to_channel[future]
                    try:
                        extracted_text = future.result()
                        if extracted_text:
                            found_keywords = check_keywords_in_text(extracted_text, extract_keywords(input_text))
                            if found_keywords:
                                st.write(f"{channel}: Found")
                            else:
                                st.write(f"{channel}: Not Found")
                    except Exception as e:
                        st.error(f"Error processing {channel}: {e}")
                        st.write(f"{channel}: Error")
        else:
            st.warning("Please enter news text.")

# Streamlit app
def main():
    st.sidebar.title("Fake News Detection")
    app_mode = st.sidebar.radio("Page Selection", ["Using ML", "Web Extraction"])
    if app_mode == "Using ML":
        ml_page()
    elif app_mode == "Web Extraction":
        web_extraction_page()

def ml_page():
    st.title("Fake News Detection using ML")
    news_input = st.text_area("Enter the news text:")
    
    if st.button("Detect"):
        if news_input:
            result = detect_fake_news(news_input)
            st.write("Prediction:", result)
        else:
            st.warning("Please enter news text.")

if __name__ == "__main__":
    main()
