importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js");

// This is required to initialize the app in the service worker
firebase.initializeApp({
    // Your firebase config details will be filled in automatically by the FlutterFire CLI
    apiKey: "AIzaSyAWVP6sol7J_rTqfujajWFV_QslVy48jR8",

  authDomain: "gymanager-aa65d.firebaseapp.com",

  projectId: "gymanager-aa65d",

  storageBucket: "gymanager-aa65d.firebasestorage.app",

  messagingSenderId: "730023436732",

  appId: "1:730023436732:web:c771508b106d16d8790bb9",

  measurementId: "G-PTE9BBBW97"

});

const messaging = firebase.messaging();