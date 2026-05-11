const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");

const app = express();

app.use(cors());

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

let waitingUsers = [];

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("joinQueue", () => {
    waitingUsers.push(socket.id);

    console.log(waitingUsers);

    if (waitingUsers.length >= 2) {
      const user1 = waitingUsers.shift();
      const user2 = waitingUsers.shift();

      io.to(user1).emit("matched", user2);
      io.to(user2).emit("matched", user1);

      console.log("Matched users");
    }
  });

  socket.on("disconnect", () => {
    waitingUsers = waitingUsers.filter(
      id => id !== socket.id
    );

    console.log("User disconnected");
  });
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});