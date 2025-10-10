# 1. Use official Python image as base
FROM python:3.10.0

# 2. Set working directory inside the container
WORKDIR /app

# 3. Copy everything from backend folder into container
COPY . .

# 4. Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 5. Expose the port Flask runs on
# EXPOSE 5000

# 6. Start the Flask server
CMD ["python", "main.py"]
