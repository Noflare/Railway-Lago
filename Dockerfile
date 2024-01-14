# Utilisez l'image de base souhaitée
FROM ubuntu:latest

# Installation des dépendances nécessaires
RUN apt-get update && apt-get install -y \
    git \
    docker \
    bash \
    curl \
    openssl


# Configuration de l'environnement local
RUN git clone --recurse-submodules git@github.com:getlago/lago.git \
    && cd lago \
    && echo "export LAGO_PATH=${PWD}" >> ~/.bashrc \
    && echo 'alias lago="docker-compose -f $LAGO_PATH/docker-compose.dev.yml"' >> ~/.bashrc \
    && source ~/.bashrc

# Ajout des domaines personnalisés au fichier /etc/hosts
RUN echo "127.0.0.1 traefik.lago.dev api.lago.dev app.lago.dev pdf.lago.dev license.lago.dev mail.lago.dev" >> /etc/hosts

# Configuration de l'API
RUN cd $LAGO_PATH \
    && cp ./api/.env.dist ./api/.env \
    && touch ./api/config/master.key

# Commandes de l'environnement local
CMD ["lago", "up", "-d", "db", "redis", "traefik", "mailhog"]
CMD ["lago", "up", "front", "api", "api-worker", "api-clock", "pdf"]

# Exécution des étapes supplémentaires du guide
CMD ["cp", "./api/.env.dist", "./api/.env"]
CMD ["touch", "./api/config/master.key"]
CMD ["lago", "exec", "license", "sh"]
CMD ["rake", "db:setup"]
CMD ["rake", "license:generate['lago',nil]"]
CMD ["echo", "export LAGO_LICENSE=<THE RESULT COPIED ABOVE> >> ~/.zshrc"]
CMD ["source", "~/.zshrc"]
CMD ["lago", "restart", "api"]

# Mise à jour de la copie locale du code
CMD ["git", "pull", "--recurse-submodules"]
