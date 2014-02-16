#include <pebble.h>

static Window *window;
static Window *menuWindow2;
MenuLayer* mainMenu;

void showDetail(MenuIndex* index); // Defined in detailView.c
static void setUpListWindow();

char hex[] = "0\0001\0002\0003\0004\0005\0006\0007\0008\0009\000A\000B\000C\000D\000E\000F";

MenuLayerCallbacks cbacks; // The Pebble API documentation says this should be long-lived
// Currently, however, MenuLayerCallbacks is a struct and the menu_layer_set_callbacks does not take a pointer to this struct as an argument.
// Instead, it takes the struct itself.  In C structs are passed by value and returned by value, so this would work fine if it were not long-lived.  
//The struct's data would be copied anyway.

//Intro Text
static TextLayer *text_layer;
static TextLayer *title_layer;

//Test
static Layer *layer;

enum {
            AKEY_NUMBER,
            AKEY_TEXT,
        };


//===========================================================
//Set introduction layers to hidden
//===========================================================
void set_introLayerHidden(bool hidden)
{
    if(hidden) {
      layer_set_hidden((Layer *)text_layer, true);
      layer_set_hidden((Layer *)title_layer, true);
      layer_set_hidden((Layer *)layer, true);
    }else{
      //Do something?
    }
}
//===========================================================
//AppMessage handlers
//===========================================================
void out_sent_handler(DictionaryIterator *sent, void *context) {
   //text_layer_set_text(text_layer, "Sent");
 }


 void out_failed_handler(DictionaryIterator *failed, AppMessageResult reason, void *context) {
   // outgoing message failed
  text_layer_set_text(text_layer, "Failed, Try Again");
 }

 void in_dropped_handler(AppMessageResult reason, void *context) {
   // incoming message dropped
 }

 void in_received_handler(DictionaryIterator *iter, void *context) {
  // Check for fields you expect to receive
  Tuple *text_tuple = dict_find(iter, AKEY_TEXT);

  // Act on the found fields received
  if (text_tuple) {
    text_layer_set_text(text_layer, text_tuple->value->cstring);
  }

}

//===========================================================
// Main Menu Call Back, This contains all the other contacts 
// in vicinity.
//===========================================================
void mainMenu_select_click(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context)
{ // Show the detail view when select is pressed.
  showDetail(cell_index); // Defined in detailView.c
}
void mainMenu_draw_row(GContext *ctx, const Layer *cell_layer, MenuIndex *cell_index, void *callback_context)
{ // Adding the row number as text on the row cell.
  graphics_context_set_text_color(ctx, GColorBlack); // This is important.
  graphics_draw_text(ctx, "contacts...", fonts_get_system_font(FONT_KEY_GOTHIC_14), GRect(0,0,layer_get_frame(cell_layer).size.w,layer_get_frame(cell_layer).size.h), GTextOverflowModeTrailingEllipsis, GTextAlignmentCenter, NULL);
  // Just saying layer_get_frame(cell_layer) for the 4th argument doesn't work.  Probably because the GContext is relative to the cell already, but the cell_layer.frame is relative to the menulayer or the screen or something.
}
void mainMenu_draw_header(GContext *ctx, const Layer *cell_layer, uint16_t section_index, void *callback_context)
{ // Adding the header number as text on the header cell.
  graphics_context_set_text_color(ctx, GColorBlack); // This is important.
  graphics_draw_text(ctx, "Users Found", fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD), GRect(0,0,layer_get_frame(cell_layer).size.w,layer_get_frame(cell_layer).size.h), GTextOverflowModeTrailingEllipsis, GTextAlignmentCenter, NULL);
}
int16_t mainMenu_get_header_height(struct MenuLayer *menu_layer, uint16_t section_index, void *callback_context)
{ // Always 30px tall for a header cell
  return 30;
}
int16_t mainMenu_get_cell_height(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context)
{ // Always 20px tall for a normal cell
  return 20;
}
uint16_t mainMenu_get_num_rows_in_section(struct MenuLayer *menu_layer, uint16_t section_index, void *callback_context)
{ // 3, 6, and 9 rows per section
  return (section_index+1)*3;
}
uint16_t mainMenu_get_num_sections(struct MenuLayer *menu_layer, void *callback_context)
{ // Always 3 sections
  return 1;
}


//===========================================================
// handlers for clicking select, up and down. 
//===========================================================

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {

bool tmp = strcmp("Connect",text_layer_get_text(text_layer));

  if(tmp == 0) {
    Layer *window_layer = window_get_root_layer(window);
    //First remove title, text_layer, and circle indicator.
    // set_introLayerHidden(true);
    setUpListWindow();

    // layer_add_child(window_get_root_layer(window), menu_layer_get_layer(mainMenu));

    //Get the data of all user contacts found.

   // if (currentText_layer)

    // //Get out a dictionary iterator for the outgoing message. 
    // DictionaryIterator *iter;
    // app_message_outbox_begin(&iter);

    // Tuplet value = TupletInteger(1, 42);
    // // Tuplet value = TupletCString("testString", "test23213213");
    // dict_write_tuplet(iter, &value);

    // app_message_outbox_send();

    //build the menu view.


  }

}

static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Up");
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Down");
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

//===========================================================
// handlers for list menu to select contact you want to add.
//===========================================================

// static void select_click_Menuhandler(ClickRecognizerRef recognizer, void *context) {

// }

// static void up_click_Menuhandler(ClickRecognizerRef recognizer, void *context) {
//   text_layer_set_text(text_layer, "Up");
// }

// static void down_click_Menuhandler(ClickRecognizerRef recognizer, void *context) {
//   text_layer_set_text(text_layer, "Down");
// }

// static void click_config_providerMenu(void *context) {
//   window_single_click_subscribe(BUTTON_ID_SELECT, select_click_Menuhandler);
//   window_single_click_subscribe(BUTTON_ID_UP, up_click_Menuhandler);
//   window_single_click_subscribe(BUTTON_ID_DOWN, down_click_Menuhandler);
// }

static void layer_update_callback(Layer *layer, GContext* ctx) {

  GRect bounds = layer_get_frame(layer);
  // Draw the large circle the image will composite with
  graphics_context_set_fill_color(ctx, GColorBlack);
  graphics_fill_circle(ctx, GPoint(bounds.size.w - 10, bounds.size.h/2 - 4), 5);
}

//===========================================================
// menuWindow_load
//===========================================================

static void menuWindow_load(Window *window) {

}

static void menuWindow_unload(Window *window) {

}

static void setUpListWindow() {

  menuWindow2 = window_create();
  Layer *window_layer = window_get_root_layer(menuWindow2);
  GRect bounds = layer_get_bounds(window_layer);

  // window_set_click_config_provider(menuWindow2, click_config_providerMenu);
  // window_set_window_handlers(menuWindow2, (WindowHandlers) {
  //     .load = menuWindow_load,
  //     .unload = menuWindow_unload,
  //   });

  //Initializations for the main menu.

  mainMenu = menu_layer_create(GRect(0,0,bounds.size.w,bounds.size.h));
  menu_layer_set_click_config_onto_window(mainMenu, menuWindow2); // Sets the Window's button callbacks to the MenuLayer's default button callbacks.
  // Set all of our callbacks.
  cbacks.get_num_sections = &mainMenu_get_num_sections; // Gets called at the beginning of drawing the table.
  cbacks.get_num_rows = &mainMenu_get_num_rows_in_section; // Gets called at the beginning of drawing each section.
  cbacks.get_cell_height = &mainMenu_get_cell_height; // Gets called at the beginning of drawing each normal cell.
  cbacks.get_header_height = &mainMenu_get_header_height; // Gets called at the beginning of drawing each header cell.
  cbacks.select_click = &mainMenu_select_click; // Gets called when select is pressed.
  cbacks.draw_row = &mainMenu_draw_row; // Gets called to set the content of a normal cell.
  cbacks.draw_header = &mainMenu_draw_header; // Gets called to set the content of a header cell.
  // cbacks.selection_changed = &func(struct MenuLayer *menu_layer, MenuIndex new_index, MenuIndex old_index, void *callback_context) // I assume this would be called whenever an up or down button was pressed.
  // cbacks.select_long_click = &func(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) // I didn't use this.
  menu_layer_set_callbacks(mainMenu, NULL, cbacks); // I have no user data to supply to the callback functions, so 
  layer_add_child(window_get_root_layer(menuWindow2), menu_layer_get_layer(mainMenu));

  const bool animated = true;

  window_stack_push(menuWindow2, animated);
}


//===========================================================
// Drawing and window loading.
//===========================================================

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  //App initially launched, Prompt with a connect icon. 
  text_layer = text_layer_create(GRect(0, bounds.size.h/2 - 20, 144, 68));
  text_layer_set_text(text_layer, "Connect");
  text_layer_set_font(text_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24));
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);

  //Title
  title_layer = text_layer_create(GRect(0, 0, 144, 68));
  text_layer_set_text(title_layer, "CONTACTS");
  text_layer_set_font(title_layer, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
  text_layer_set_text_alignment(title_layer, GTextAlignmentCenter);

  //Circle layer to indicate which button to press on the pebble.
  layer = layer_create(bounds);
  //Set up layer callback
  layer_set_update_proc(layer, layer_update_callback);

  // Add the layers to the window for display
  layer_add_child(window_layer, text_layer_get_layer(title_layer));
  layer_add_child(window_layer, text_layer_get_layer(text_layer));
  layer_add_child(window_layer, layer);
}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);

}


static void init(void) {
  //TODO: define a marco fo rthis.
  // Layer *window_layer = window_get_root_layer(window);
  // GRect bounds = layer_get_bounds(window_layer);

   app_message_register_inbox_received(in_received_handler);
   app_message_register_inbox_dropped(in_dropped_handler);
   app_message_register_outbox_sent(out_sent_handler);
   app_message_register_outbox_failed(out_failed_handler);

   const uint32_t inbound_size = 64;
   const uint32_t outbound_size = 64;
   app_message_open(inbound_size, outbound_size);

  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  window_destroy(window);
  window_destroy(menuWindow2);
  menu_layer_destroy(mainMenu);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
