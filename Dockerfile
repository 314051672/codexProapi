FROM node:20-alpine
RUN npm install -g codex-proapi
ENV PORT=1455
EXPOSE 1455
CMD ["sh", "-lc", "exec codex-proapi"]
