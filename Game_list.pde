public class games {
  // Variables
  private float x, y, Wscale, Hscale, Xanim = 10, Yanim = 10, Sanim;
  private String text, text2;
  private boolean hover;
  private color box;
  private boolean pressed;
  
  // Constructor
  public games(float x, float y, float Wscale, float Hscale, String text, String host) {
    this.x = x;
    this.y = y;
    this.Wscale = Wscale;
    this.Hscale = Hscale;
    this.text = text;
    this.text2 = host;
  }

  void draws() {
    // check if hover
    if (mouseX >= x - Wscale/1.5 && mouseX <= x + Wscale/1.5 && mouseY >= y - Hscale/1.5 && mouseY <= y + Hscale/1.5) hover(true);
    else hover(false);
    
    // check if pressed
    if (hover == true && keys[0]) {
      pressed = true;
    }
    // Animation
    if (pressed == true && Xanim > 0) {
      Xanim -= 2.5;
      Yanim -= 2.5;
    }
    if (Xanim <=0) {
      noStroke();
      fill(box);
      circle(x, y, Sanim);
      Sanim += 60;
    }
    
    // Design
    push();
    
    // Box
    fill(255);
    rectMode(CENTER);
    stroke(255);
    strokeWeight(10);
    strokeJoin(ROUND);
    rect(x, y, Wscale, Hscale);
    fill(box);
    stroke(box);
    rect(x-Xanim, y-Yanim, Wscale, Hscale);
    
    // Text
    fill(250);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(text, x-Xanim, y-Yanim);
    pop();
  }
  
  void hover(boolean check) {
    if (check == true) {
    hover = true;
    box = #9A069B;
    } else {
      hover = false;
      box = 20;
    }
  }
}
