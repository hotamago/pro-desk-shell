use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new_qml_module(
        QmlModule::new("io.hotamago.shell").qml_files(["qml/BackendMarker.qml"]),
    )
    .file("src/shell_state.rs")
    .build();
}
