#include "include/flutter_custom_cursor/flutter_custom_cursor_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <sys/utsname.h>

#include <cstring>

#define FLUTTER_CUSTOM_CURSOR_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_custom_cursor_plugin_get_type(), \
                              FlutterCustomCursorPlugin))

struct _FlutterCustomCursorPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(FlutterCustomCursorPlugin, flutter_custom_cursor_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow* get_window(FlutterCustomCursorPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr)
    return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

GdkWindow* get_gdk_window(FlutterCustomCursorPlugin* self) {
  return gtk_widget_get_window(GTK_WIDGET(get_window(self)));
}
//  <String, dynamic>{
//     'device': device,
//     'path': cursor.path,
//     'x' : cursor.x,
//     'y' : cursor.y,
//   },
static void activate_cursor(GtkWindow* window, FlValue* args) {
   // TODO
   //const gchar* cursor_path = fl_value_get_string(fl_value_lookup_string(args, "path"));
   double x = fl_value_get_float(fl_value_lookup_string(args, "x"));
   double y = fl_value_get_float(fl_value_lookup_string(args, "y"));
   //int device = fl_value_get_int(fl_value_lookup_string(args, "device"));

   GdkDisplay* display = gdk_display_get_default();

   GtkImage* image = GTK_IMAGE(gtk_image_new_from_file("/home/kingtous/Downloads/mouse.png"));
   GdkPixbuf* pixbuf = gtk_image_get_pixbuf(image);
   auto cursor = gdk_cursor_new_from_pixbuf(display, pixbuf ,x, y);
   gdk_window_set_cursor(gtk_widget_get_window(GTK_WIDGET(window)), cursor);
   // TODO
  //  fl_get_windo
}
#include <iostream>
// Called when a method call is received from Flutter.
static void flutter_custom_cursor_plugin_handle_method_call(
    FlutterCustomCursorPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  GtkWindow* window = get_window(self);

  const gchar* method = fl_method_call_get_name(method_call);
  std::cout << "called";
  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "activateCursor") == 0) {
    auto args = fl_method_call_get_args(method_call);
    activate_cursor(window, args);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_custom_cursor_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_custom_cursor_plugin_parent_class)->dispose(object);
}

static void flutter_custom_cursor_plugin_class_init(FlutterCustomCursorPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_custom_cursor_plugin_dispose;
}

static void flutter_custom_cursor_plugin_init(FlutterCustomCursorPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlutterCustomCursorPlugin* plugin = FLUTTER_CUSTOM_CURSOR_PLUGIN(user_data);
  flutter_custom_cursor_plugin_handle_method_call(plugin, method_call);
}

void flutter_custom_cursor_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterCustomCursorPlugin* plugin = FLUTTER_CUSTOM_CURSOR_PLUGIN(
      g_object_new(flutter_custom_cursor_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "flutter_custom_cursor",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}