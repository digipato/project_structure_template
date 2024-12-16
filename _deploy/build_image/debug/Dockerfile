# Usa l'immagine Python
FROM python:3.11-slim

# Imposta la directory di lavoro
WORKDIR /app

# Copia i file di progetto
COPY ./requirements.txt /

# Installa le dipendenze
RUN pip install --no-cache-dir -r /requirements.txt

# Espone la porta
EXPOSE 8000

# Comando di avvio
RUN pip install debugpy
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "manage.py", "runserver", "0.0.0.0:8000"]
