/**
 * 
 * @author Godin Stanislas
 *
 */

public class buttons {
  // Variables
  private float x, y, Wscale, Hscale;
  private String text;
  private color box, boxHover, image;
  private int type;
  public boolean pressed = false;
  private PImage img;

  // Constructor
  public buttons(float x, float y, float Wscale, float Hscale, int type, String text, PImage img) {
    this.x = x;
    this.y = y;
    this.Wscale = Wscale;
    if (this.Wscale < 100) this.Wscale = 100;
    this.Hscale = Hscale;
    this.text = text;
    this.type = type;
    this.img = img;
    this.box = colors[2];
    this.boxHover = colors[4];
    // this.boxHover = style == 1 ? #891A1C : #ffaa5e;
    // if (style == 2) {
    //   this.box = #ffaa5e; 
    //   this.boxHover = #ffd4a3;
    // }
  }

  void draws() {
    //Hover
    if (Hover(x, y, Wscale, Hscale) || pressed) box = boxHover;
    else box = colors[2];

    // Design
    push();
    textSize(25);
    textAlign(CENTER, CENTER);
    strokeJoin(ROUND);
    rectMode(CENTER);
    strokeWeight(10);
    switch (type) {
      case 0:
        // Box
        // fill(#ffecd6);
        // stroke(#ffecd6);
        // rect(x, y, Wscale, Hscale);
        fill(box);
        stroke(box);
        rect(x, y, Wscale, Hscale);
        fill(0);
        text(text, x, y);
        break;
      case 1: // images
        fill(box);
        stroke(box);
        rect(x, y, Wscale, Hscale);
        imageMode(CENTER);
        if (img != null)
          image(img, x, y, Wscale, Hscale);
        break;
    }
    pop();
  }

  //Check if mouse is Over
  boolean Hover(float x, float y, float w, float  h) {
    if (mouseX >= x - w/1.5 && mouseX <= x + w/1.5 && mouseY >= y - h/1.5 && mouseY <= y + h/1.5) return true;
    return false;
  }

  //Check if mouse is pressed on button
  boolean Pressed() {
    if (Hover(x, y, Wscale, Hscale) && keys[0])
      return true;
    return false;
  }
}