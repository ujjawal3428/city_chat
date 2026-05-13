const express = require("express");
const http = require("http");
const { Server } = require("socket.io");

const app = express();

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

let waitingUser = null;

io.on("connection", (socket) => {
  console.log("User connected");

  socket.on("joinQueue", () => {
    if (waitingUser) {
      socket.partner = waitingUser.id;
      waitingUser.partner = socket.id;

      socket.emit("matched", waitingUser.id);

      waitingUser.emit("matched", socket.id);

      waitingUser = null;
    } else {
      waitingUser = socket;
    }
  });

  socket.on("message", (message) => {
    if (socket.partner) {
      io.to(socket.partner).emit("message", message);
    }
  });

  socket.on("disconnect", () => {
    console.log("User disconnected");
  });
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});