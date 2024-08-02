import http.requests.*;
WebsocketClient ws;

boolean keys[] = new boolean[10];
buttons[] button;
buttons[] mapButton;
buttons[] gameTypeButton;
buttons[] playerNumberButton;
ArrayList<notification> notify = new ArrayList<notification>();
String state = "Main-Menu";
Boolean login = false;
JSONArray gameList = new JSONArray();
String sessionId;// = "qztz6zy6rxwd62wqlq6f544y21r0n3f9";
String csrfToken;
String token;
int gameId = 6;
JSONObject gameStateJson;
float scrollOffset = 0;

// colors text background primary secondary accent
boolean isDarkMode = false;
color[] lightColors = {#162227, #D8E4E9, #17a2ee, #7A89F5, #4D41F1};
color[] darkColors = {#ECFBFE, #162227, #119de8, #0A1885, #1A0EBE};
color[] colors = isDarkMode ? darkColors : lightColors;

void switchMode() {
  isDarkMode = !isDarkMode;
  colors = isDarkMode ? darkColors : lightColors;
}

// Login

import java.net.HttpURLConnection;
import java.net.URL;
import java.io.OutputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;
import java.util.Map;

// Dev
Boolean dev = true;

class Vertex {
  float x, y;

  Vertex(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class Obstacle {
  String type;
  Vertex[] vertices;

  // Constructor for rectangle
  Obstacle(String type, JSONArray verticesArr) {
    // print(type);
    this.type = type;
    vertices = new Vertex[verticesArr.size()];
    for (int i = 0; i < verticesArr.size(); i++) {
      JSONObject vertex = verticesArr.getJSONObject(i);
      this.vertices[i] = new Vertex(vertex.getFloat("x"), vertex.getFloat("y"));
    }
  }
}

// Setup //
void setup() {
  size(800, 600);
  frameRate(180);
  background(colors[1]);
  create_button();

  // Dev
  if (dev) {
    try {

    String username = "yuki";
    String password = "test";

    URL url = new URL("http://127.0.0.1:8000/login");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST");
    conn.setDoOutput(true);
    String postData = "username=" + username + "&password=" + password;
    conn.getOutputStream().write(postData.getBytes());

    BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String line;
    StringBuilder response = new StringBuilder();
    while ((line = reader.readLine()) != null) {
      response.append(line);
    }
    reader.close();

    JSONObject json = parseJSONObject(response.toString());
    String message = json.getString("token");
    token = message;
    println(token);
    // println(message);

    Map<String, List<String>> headerFields = conn.getHeaderFields();
    List<String> cookiesHeader = headerFields.get("Set-Cookie");
    if (cookiesHeader != null) {
      for (String cookie : cookiesHeader) {
        if (cookie.startsWith("sessionid")) {
          sessionId = cookie.split(";")[0].split("=")[1];
          // println(sessionId);
        }
        if (cookie.startsWith("csrftoken")) {
          csrfToken = cookie.split(";")[0].split("=")[1];
          // println(sessionId);
        }
      }
    }

    login = true;
    get_user_info();
    }
    catch (Exception e) {
      println(e.getMessage());
    }
  }

  // ws.connect();
}

Obstacle[] map;
void webSocketEvent(String msg) {
  if (msg == null) return;
  JSONObject obj = parseJSONObject(msg);
  // // Parse the JSON message
  if (msg.contains("error")) {
    // if (parseJSONObject(msg).getString("error").equals("Game not started yet."))
    //   if (notify.size() == 0)
    //     notify.add(new notification("Waiting other player", width/2, height/10, int(textWidth("Waiting other player")*2.5), 40, 3));
    return;
  }
  if (obj.hasKey("message") && obj.getString("message").equals("Setup")) {
    print(msg);
    if (!obj.hasKey("setting"))
      return;
    map = new Obstacle[obj.getJSONObject("setting").getJSONArray("obstacles").size()];
    JSONArray obstacles = obj.getJSONObject("setting").getJSONArray("obstacles");
    print(obstacles);
    for (int i = 0; i < obstacles.size(); i++) {
      JSONObject obstacle = obstacles.getJSONObject(i);
      String type = obstacle.getString("type");
      JSONArray vertices = obstacle.getJSONArray("vertices");
      print(vertices);
      if (type != null && vertices != null)
      {
        print("ok");
        map[i] = new Obstacle(type, vertices);
        print("ko");
      }
    }
  }
  else
    gameStateJson = parseJSONObject(msg);
}

void create_button() {
  button = new buttons[8];
  button[5] = new buttons(width/2, height/3 - 80, textWidth("Register")*2.5, 40, 0, "Register", null);
  button[0] = new buttons(width/2, height/3, textWidth("Login")*2.5, 40, 0, "Login", null);
  button[1] = new buttons(width/2, height/3, textWidth("Log out")*2.5, 40, 0, "Log out", null);
  button[4] = new buttons(width/2, height/3 + 80, textWidth("Create")*2.5, 40, 0, "Create", null);
  button[2] = new buttons(width/2, height/3 + 80*2, textWidth("List")*2.5, 40, 0, "List", null);
  button[3] = new buttons(width/2, height/3 + 80*4, textWidth("Back")*2.5, 40, 0, "Back", null);
  button[6] = new buttons(width/2, height/3 + 80*3, textWidth("Switch")*2.5, 40, 0, "Switch", null);
  button[7] = new buttons(width - width/textWidth("Profile")*2.5 - 20, height/10, textWidth("Profile")*2.5, 40, 0, "Profile", null);

  // map image
  PImage mapImage[] = new PImage[4];
  mapImage[0] = loadImage("0.png");
  mapImage[1] = loadImage("1.png");
  mapImage[2] = loadImage("2.png");
  mapImage[3] = loadImage("3.png");
  // pong setting button
  mapButton = new buttons[4]; 
  int x = 40 + 100*2;
  int y = height/10 + 40 + 20;
  int gap = 20;
  for (int i = 0; i < mapButton.length; i++) {
    mapButton[i] = new buttons(x + gap*i + 100*i, y, 100, 50, 1, "test map", mapImage[i]);
  }
  gameTypeButton = new buttons[2];
  gameTypeButton[0] = new buttons(x, y + 40*2, textWidth("default")*2.5, 40, 0, "default", null);
  gameTypeButton[1] = new buttons(x + gap*1 + 100*1, y + 40*2, textWidth("custom")*2.5, 40, 0, "custom", null);
  playerNumberButton = new buttons[2];
  playerNumberButton[0] = new buttons(x, y + 40*4, textWidth("solo")*2.5, 40, 0, "solo", null);
  playerNumberButton[1] = new buttons(x + gap*1 + 100*1, y + 40*4, textWidth("duo")*2.5, 40, 0, "duo", null);

}

void draw() {
  background(colors[1]);
  pages();
  CheckKeys();
  
  if (notify.size() > 0) {
    notification currentNotification = notify.get(0);
    currentNotification.display();
    if (!currentNotification.visible)
      notify.remove(0);
  }
  ClearKeys();
}

int lastMoveTime = 0;
int lastMoveTime2 = 0;
int moveCooldown = 50; // Cooldown period in milliseconds

int user_id;

void CheckKeys() { // No need 
  int currentTime = millis(); // TODO : cooldown at server level
  if (currentTime - lastMoveTime > moveCooldown) {
    if (keys[2]) {
      move(gameId, "up");
      lastMoveTime = currentTime;
    } else if (keys[3]) {
      move(gameId, "down");
      lastMoveTime = currentTime;
    }
  }
}

// form
import java.util.List;
import java.util.Map;
import javax.swing.*;
import java.awt.GridLayout;

void register() {
  try {
    // Create a JPanel with two text fields
    JPanel panel = new JPanel(new GridLayout(2, 2));
    JTextField usernameField = new JTextField();
    JTextField emailField = new JTextField();
    JTextField passwordField = new JPasswordField();
    panel.add(new JLabel("Username:"));
    panel.add(usernameField);
    panel.add(new JLabel("Email:"));
    panel.add(emailField);
    panel.add(new JLabel("Password:"));
    panel.add(passwordField);

    // Show the JPanel in a dialog
    int result = JOptionPane.showConfirmDialog(null, panel, "Register", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
    if (result == JOptionPane.OK_OPTION) {
      // If the user clicked OK, get the entered username and password
      String username = usernameField.getText();
      String password = new String(passwordField.getText());
      String email = emailField.getText();

      URL url = new URL("http://127.0.0.1:8000/register");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setDoOutput(true);
      String postData = "username=" + username + "&password=" + password + "&email=" + email;
      conn.getOutputStream().write(postData.getBytes());
      if (conn.getResponseCode() != 200) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
        String line;
        StringBuilder response = new StringBuilder();
        while ((line = reader.readLine()) != null) {
          response.append(line);
        }
        reader.close();
        JSONObject json = parseJSONObject(response.toString());
        String message = json.getString("error");
        notify.add(new notification(message, width/2, height/10, int(textWidth(message)*2.5), 40, 3));
        return;
      }

      BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      String line;
      StringBuilder response = new StringBuilder();
      while ((line = reader.readLine()) != null) {
        response.append(line);
      }
      reader.close();

      JSONObject json = parseJSONObject(response.toString());
      String message = json.getString("message");
      // println(message);

      Map<String, List<String>> headerFields = conn.getHeaderFields();
      List<String> cookiesHeader = headerFields.get("Set-Cookie");
      if (cookiesHeader != null) {
        for (String cookie : cookiesHeader) {
          // println(cookie);
          if (cookie.startsWith("sessionid")) {
            sessionId = cookie.split(";")[0].split("=")[1];
            // println(sessionId);
          }
          if (cookie.startsWith("csrftoken")) {
            csrfToken = cookie.split(";")[0].split("=")[1];
            // println(csrfToken);
            // println(sessionId);
          }
        }
      }

      login = true;
    }
  } catch (Exception e) {
    // println(e.getMessage());
  }
}

String username = "undefined";

void get_user_info() {
  String url = "http://127.0.0.1:8000/me";
  GetRequest get = new GetRequest(url);

  get.addHeader("Cookie", "sessionid=" + sessionId); // Add the session ID as a cookie
  get.addHeader("Authorization", "Bearer " + token);
  get.send();
  try {
    JSONObject json = parseJSONObject(get.getContent());
    username = json.getString("username");
    user_id = json.getInt("id");
    notify.add(new notification("Welcome " + username, width/2, height/10, int(textWidth("Welcome " + username)*2.5), 40, 3));
  } catch (Exception e) {
    // println(e.getMessage());
  }
}

void login() {
  try {
    // Create a JPanel with two text fields
    JPanel panel = new JPanel(new GridLayout(2, 2));
    JTextField usernameField = new JTextField();
    JTextField passwordField = new JPasswordField();
    panel.add(new JLabel("Username:"));
    panel.add(usernameField);
    panel.add(new JLabel("Password:"));
    panel.add(passwordField);

    // Show the JPanel in a dialog
    int result = JOptionPane.showConfirmDialog(null, panel, "Login", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
    if (result == JOptionPane.OK_OPTION) {
      // If the user clicked OK, get the entered username and password
      String username = usernameField.getText();
      String password = new String(passwordField.getText());

      URL url = new URL("http://127.0.0.1:8000/login");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setDoOutput(true);
      String postData = "username=" + username + "&password=" + password;
      conn.getOutputStream().write(postData.getBytes());
      if (conn.getResponseCode() != 200) {
        println("error login");
        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
        String line;
        StringBuilder response = new StringBuilder();
        while ((line = reader.readLine()) != null) {
          response.append(line);
        }
        reader.close();
        JSONObject json = parseJSONObject(response.toString());
        String message = json.getString("message");
        notify.add(new notification(message, width/2, height/10, int(textWidth(message)*2.5), 40, 3));
        return;
      }

      BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      String line;
      StringBuilder response = new StringBuilder();
      while ((line = reader.readLine()) != null) {
        response.append(line);
      }
      println(response.toString());
      reader.close();

      JSONObject json = parseJSONObject(response.toString());
      token = json.getString("token");
      user_id = json.getInt("UserId");

      // println(message);
      notify.add(new notification(token, width/2, height/10, int(textWidth(token)*2.5), 40, 3));

      Map<String, List<String>> headerFields = conn.getHeaderFields();
      List<String> cookiesHeader = headerFields.get("Set-Cookie");
      if (cookiesHeader != null) {
        for (String cookie : cookiesHeader) {
          if (cookie.startsWith("sessionid")) {
            sessionId = cookie.split(";")[0].split("=")[1];
          }
          if (cookie.startsWith("csrftoken")) {
            csrfToken = cookie.split(";")[0].split("=")[1];
            // println(sessionId);
          }
        }
      }

      login = true;
      get_user_info();
    }
  } catch (Exception e) {
    // println(e.getMessage());
  }
}

void logout() {
  PostRequest post = new PostRequest("http://127.0.0.1:8000/logout");
  post.send();
  String message = "ERROR";
  try {
    JSONObject json = parseJSONObject(post.getContent()); // TODO : check response
    String error = json.getString("error");
    message = json.getString("message");
  } catch (Exception e) {
    // println(e.getMessage());
  }
  login = false;
  notify.add(new notification(message, width/2, height/10, int(textWidth(message)*2.5), 40, 3));
}

void list_party() {
  GetRequest get = new GetRequest("http://127.0.0.1:8001/game/party");
  get.send();
  try {
    gameList = new JSONArray();
    JSONArray jsonArray = parseJSONArray(get.getContent());
    for (int i = 0; i < jsonArray.size(); i++) {
      JSONObject game = jsonArray.getJSONObject(i);
      gameList.setJSONObject(gameList.size(), game);
      // println(gameList.getJSONObject(i));
    }
  } catch (Exception e) {
    // println(e.getMessage());
  }
}
import java.lang.reflect.Field;
import org.apache.http.HttpResponse;

int getStatusCode(Object request) {
  try {
    Field responseField = request.getClass().getDeclaredField("response");
    responseField.setAccessible(true);
    HttpResponse response = (HttpResponse) responseField.get(request);
    int statusCode = response.getStatusLine().getStatusCode();
    return statusCode;
  } catch (Exception e) {
      e.printStackTrace();
      return -1;
  }
}

int scroll = 0;
void slideShow(ArrayList arr, int x, int y) {
//   buttons back = new buttons(x - 40*4 -20, y, 40, 40, 0, "<");
//   buttons next = new buttons(x + 40*4 +20, y, 40, 40, 0, ">");
//   int gap = 20;
//   buttons[] showButtons = new buttons[arr.size()];
//   for (int i = 0; i < arr.size(); i++) {
//     showButtons[i] = new buttons(x + gap*i + 100*i + scroll, y, 100, 40, 1, (String) arr.get(i));
//     showButtons[i].draws();
//   }

//   customRect(0, y - 40, x - 40*3 , y + 40, 0);
//   customRect(x + 40*3, y - 40, width, y + 40, 1);
//   back.draws();
//   next.draws();
//   if (back.Pressed()) {
//     if (scroll < 0)
//       scroll += 120;
//   }
//   if (next.Pressed()) {
//     if (scroll > -120*(arr.size()-1))
//       scroll -= 120;
//   }

}

JSONObject pongSettings = new JSONObject();
// pongSettings.setString("gameType", "default");
// pongSettings.setInt("map", 0);

void handlePongSettingButtons(buttons[] buttons, String settingName, String text, int textPosition) {
  int gap = 20;
  customText(text, width/20, height/10 + 40*textPosition + gap, false);
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].draws();
    if (buttons[i].Pressed()) {
      buttons[i].pressed = true;
      pongSettings.setInt(settingName, i);
      for (int j = 0; j < buttons.length; j++) {
        if (j != i) {
          buttons[j].pressed = false;
        }
      }
    }
  }
}

void createMenu() {
  customText("Create Party", width/2, height/10, true);
  // map:
  handlePongSettingButtons(mapButton, "map", "Map: ", 1);
  // gameType
  handlePongSettingButtons(gameTypeButton, "gameType", "Mode: ", 3);
  // player
  handlePongSettingButtons(playerNumberButton, "playerNumber", "Player: ", 5);


  buttons create = new buttons(width/2, height/3 + 80*3, textWidth("Create")*2.5, 40, 0, "Create", null);
  create.draws();
  if (create.Pressed()) {
    create_party();
  }

  button[3].draws();
  if (button[3].Pressed()) {
    state = "Main-Menu";
  }
}

void create_party() {
  String url = "http://127.0.0.1:8001/game/create";
  PostRequest post = new PostRequest(url);

  post.addHeader("Cookie", "sessionid=" + sessionId); // Add the session ID as a cookie
  post.addHeader("Authorization", "Bearer " + token);
  post.addData("game", "pong");
  post.addData("UserId", String.valueOf(user_id));
  // post.addData("playerNumber", "2");
  for (Object keyObj : pongSettings.keys()) {
    String key = (String) keyObj;
    Object value = pongSettings.get(key);
    if (key.equals("playerNumber")) {
      int intValue = (int) value;
      intValue++;
      value = Integer.toString(intValue);
    }
    post.addData(key, value.toString());
  }
  //post.addHeader("Cookie", "csrftoken=" + csrfToken); // Add the session ID as a cookie
  post.send();
  // JsonResponse({'message': 'Game started', 'game_id': game.id})
  if (getStatusCode(post) != 200) {
    JSONObject json = parseJSONObject(post.getContent());
    String message = json.getString("error");
    notify.add(new notification(message, width/2, height/10, int(textWidth(message)*2.5), 40, 3));
    return;
  }
  gameId = JSONObject.parse(post.getContent()).getInt("game_id");

  
  // ws
  StringList headers = new StringList();
  headers.append("User-Agent:Processing");
  ws = new WebsocketClient(this, "ws://localhost:8001/ws/pong/" + gameId + "/" + token + "/" + user_id, headers);
  state = "Game";
}

void join_game(int id) {
  String url = "http://127.0.0.1:8001/game/join?gameId=" + id;
  PostRequest post = new PostRequest(url);
  // println(sessionId);
  post.addHeader("Cookie", "sessionid=" + sessionId); // Add the session ID as a cookie
  post.addHeader("Authorization", "Bearer " + token);
  post.addData("UserId", String.valueOf(user_id));
  post.send();
  try {
    if (getStatusCode(post) != 200) {
      JSONObject json = parseJSONObject(post.getContent());
      String message = json.getString("error");
      notify.add(new notification(message, width/2, height/10, int(textWidth(message)*2.5), 40, 3));
      // return;
    }
    // println(post.getContent());
    state = "Game";
    gameId = id;

    // ws
    StringList headers = new StringList();
    headers.append("User-Agent:Processing");
    ws = new WebsocketClient(this, "ws://localhost:8001/ws/pong/" + gameId + "/" + token + "/" + user_id, headers);
  } catch (Exception e) {
    notify.add(new notification("Error", width/2, height/10, int(textWidth("Error")*2.5), 40, 3));
  }
}

void customText(String text, float x, float y, boolean align) {
  push();
  fill(colors[0]);
  textSize(28);
  if (align)
    textAlign(CENTER, CENTER);
  else
    textAlign(LEFT, CENTER);
  text(text, x, y);
  pop();
}

void customRect(float x, float y, float w, float h, int c) {
  push();
  fill(colors[c]);
  stroke(colors[c]);
  rect(x, y, w, h);
  pop();
}

JSONObject player_stats;
JSONArray game_history;

void profile() {
  customRect(0, 0, width, height, 1);
  customText("Profile", width/2, height/10, true);
  customText("Username: " + username, width/2, height/3, true);
  customText("Pong stats: ", width/4, height/3 + 40, true);
  // stats
  int gap = 40;
  int i = 0;
  if (player_stats != null) {
    // pong
    if (player_stats.hasKey("pong")) {
      JSONObject pong_stats = player_stats.getJSONObject("pong");
      for (Object keyObj : pong_stats.keys()) {
        String key = (String) keyObj;
        Object value = pong_stats.get(key);
        customText(key + ": " + value, width/4, height/3 + 40 + 40 + gap*i, true);
        i++;
      }
    }
    else 
      customText("No pong stats", width/4, height/3 + 40 + 40, true);
  }
  else 
    customText("No stats", width/4, height/3 + 40 + 40, true);


  // history
  customText("Game history: ", width/2 + width/4, height/3 + 40, true);
  if (game_history != null) {
    for (int j = 0; j < game_history.size(); j++) {
      JSONObject game = game_history.getJSONObject(j);
      int gameNumber = game.getInt("game");
      String result = "lost";
      if (game.getInt("score") == 10) {
        result = "won";
      }
      customText(gameNumber + ": " + result, width/2 + width/4, height/3 + 40 + 40 + gap*j, true);
    }
  }
  else 
    customText("No game history", width/2 + width/4, height/3 + 40 + 40, true);
  button[3].draws();
  if (button[3].Pressed()) {
    state = "Main-Menu";
  }

}

void update_history() {
  GetRequest get = new GetRequest("http://127.0.0.1:8001/game/hist?UserId=" + user_id);
  get.addHeader("Cookie", "sessionid=" + sessionId); // Add the session ID as a cookie
  get.addHeader("Authorization", "Bearer " + token);
  get.send();
  try {
    game_history = parseJSONArray(get.getContent());
  } catch (Exception e) {
    // println(e.getMessage());
  }
}

void update_profile() {
  GetRequest get = new GetRequest("http://127.0.0.1:8001/game/stats?UserId=" + user_id);
  get.addHeader("Cookie", "sessionid=" + sessionId); // Add the session ID as a cookie
  get.addHeader("Authorization", "Bearer " + token);
  get.send();
  try {
    player_stats = parseJSONObject(get.getContent());
  } catch (Exception e) {
    // println(e.getMessage());
  }
}

void mainMenu() {
  customText("Main Menu", width/2, height/10, true);
  if (!login)
  {
    button[0].draws(); // login
    button[5].draws(); // register
    button[6].draws(); // switch
  }
  else
  {
    button[1].draws(); // logout
    button[2].draws(); // list party
    button[4].draws(); // create party
    button[6].draws(); // switch
    customText(username, width - width/textWidth("Profile")*2.5 - 40 - textWidth(username)*3, height/10, true);
    button[7].draws(); // profile
  }

  if (button[7].Pressed()) {
    update_profile();
    update_history();
    state = "Profile";
  }

  if (button[6].Pressed()) {
    switchMode();
  }

  if (!login && button[0].Pressed()) {
    login();
  }
  else if (!login && button[5].Pressed()) {
    register();
  }
  else if (login && button[1].Pressed()) {
    logout();
  }
  else if (login && button[2].Pressed()) {
    list_party();
    state = "List-Party";
    scrollOffset = 0;
  }
  else if (login && button[4].Pressed()) {
    // create_party();
    state = "Create-Menu";
  }
}

void partyMenu() {
  buttons[] party = new buttons[gameList.size()];
  int itemsPerRow = 4;
  float gap = 20;
  for (int i = 0; i < gameList.size(); i++) {

    JSONObject game = gameList.getJSONObject(i);
    String name = game.getString("gameName");
    int id = game.getInt("id");
    String str = name + " " + id;

    if (scrollOffset < 0){
      scrollOffset = 0;
    }
    if (scrollOffset > gameList.size()*60 - height/3) {
      scrollOffset = gameList.size()*60 - height/3;
    }
    
    // Calculate the row and column based on the index and the number of items per row
    int row = i / itemsPerRow;
    int col = i % itemsPerRow;

    // Calculate the x and y positions based on the row and column
    float xPos = width/2 + (col - itemsPerRow / 2.0 + 0.5) * (textWidth(str)*2.5 + gap);
    float yPos = height/3 + row * 60 - scrollOffset;
    
    party[i] = new buttons(xPos, yPos, textWidth(str)*2.5, 40, 0, str, null);
    party[i].draws();
    if (mouseY < height/3 + 80*3.5 && party[i].Pressed()) {
      join_game(id);
    }
  }
  customRect(0, 0, width, height/7, 1);
  customText("List Party", width/2, height/10, true);
  customRect(0, height/3 + 80*3.5, width, height/3, 1);
  button[3].draws();
  if (button[3].Pressed()) {
    state = "Main-Menu";
  }
}

void settingMenu() {
  customText("Settings", width/2, height/10, true);
  customRect(0, 0, width, height/7, 1);
  customRect(0, height/3 + 80*3.5, width, height/3, 1);
  button[3].draws();
  if (button[3].Pressed()) {
    state = "Main-Menu";
  }

}

void pages() {
  switch(state) {
    case "Main-Menu":
      mainMenu();
      break;
    case "List-Party":    
      partyMenu();
      break;
    case "Profile":
      profile();
      break;
    case "Create-Menu":
      createMenu();
      break;
    case "Game":
      pong();
      button[3].draws();
      if (button[3].Pressed()) {
        ws.disconnect();
        state = "Main-Menu";
      }
      break;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scrollOffset += e*20; // Adjust the scroll speed by changing the multiplier
}

class Ball extends PVector {
  float dx;
  float dy;

  Ball(float x, float y, float dx, float dy) {
    super(x, y);
    this.dx = dx;
    this.dy = dy;
  }
}

void pong() {
  if (gameStateJson == null) return;
  if (gameStateJson.getString("state").equals("waiting")) {
    customText("Waiting for other player", width/2, height/2, true);
    return;
  }
  else if (gameStateJson.getString("state").equals("finished")) {
    JSONArray scores = gameStateJson.getJSONArray("scores");
    JSONArray names = gameStateJson.getJSONArray("usernames");
    boolean first = scores.getInt(0) > scores.getInt(1);
    if (names.getString(0).equals(username) && first) {
        customText("You won", width/2, height/2, true);
    }
    else if (names.getString(1).equals(username) && !first) {
        customText("You won", width/2, height/2, true);
    }
    else {
        customText("You lost", width/2, height/2, true);
    }
    return;
  }

  Ball ball = new Ball(gameStateJson.getInt("x"), gameStateJson.getInt("y"), 0, 0);
  
  push();
  fill(colors[0]);
  ellipse(ball.x, ball.y, 15, 15);

  // Background
	for(int i=5;i<height;i+=20) {
    rect(width/2,i,4,10);
  }

  // text settings
  textSize(32);
  textAlign(CENTER);

  // Score
  JSONArray scores = gameStateJson.getJSONArray("scores");
  text(scores.getInt(0), width/2 - 50, 50);
  text(scores.getInt(1), width/2 + 50, 50);

  // player name
  JSONArray names = gameStateJson.getJSONArray("usernames");
  text(names.getString(0), 75, 50);
  text(names.getString(1), width - 75, 50);

  // Player Bar
  rectMode(CENTER);
  stroke(colors[0]);
  strokeWeight(5);
  strokeJoin(ROUND);
  JSONArray positions = gameStateJson.getJSONArray("positions");
  rect(40, positions.getInt(0), 10, 100);
  rect(width - 40, positions.getInt(1), 10, 100);

  // Draw obstacle shapes
  for (Obstacle obstacle : map) {
    if (obstacle == null)
      break;
    beginShape();
    for (Vertex vertex : obstacle.vertices) {
      if (vertex == null)
        break;
      vertex(vertex.x, vertex.y);
    }
    endShape(CLOSE);
  }

  pop();
}

void move(int gameId, String direction) {
  // println("Moving " + direction);
  PostRequest post = new PostRequest("http://127.0.0.1:8001/game/game/" + gameId + "/move");
  post.addData("direction", direction);
  post.addHeader("Cookie", "sessionid=" + sessionId); // Add the session ID as a cookie
  post.send();

  // println(post.getContent());
}

// Clear the keys
void ClearKeys () {
  keys[0] = false;
  keys[1] = false;
}

void keyPressed() {
  // println(keyCode);
  // if (keyCode == UP) move(gameId, "up");
  // else if (keyCode == DOWN) move(gameId, "down");
  // Create a JSON object with the move command
  JSONObject json = new JSONObject();
  json.setString("command", "move");
  json.setString("direction", keyCode == UP ? "up" : "down");
  json.setString("sessionId", sessionId);
  json.setString("token", token);

  // Send the move command over the WebSocket connection
  ws.sendMessage(json.toString());
}

void keyReleased() {
  if (keyCode == UP) keys[2] = false;
  if (keyCode == DOWN) keys[3] = false;
}

void mouseClicked() {
  if (mouseButton == LEFT) keys[0] = true;
  if (mouseButton == RIGHT) keys[1] = true;
}
