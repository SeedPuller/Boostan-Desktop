#include "header/base/settings.h"
#include <QDebug>

Settings::Settings()
{

}

void Settings::setValue(const QString key, const QString value, const bool raw_key)
{
    // The '//' is used in .ini format files to categorize the information
    if (raw_key) {
        settings.setValue(key, value);
        return;
    }
    settings.setValue(prefix_url % QStringLiteral("//") % prefix_uid % QStringLiteral("//") % key, value);
}

QVariant Settings::getValue(const QString key, const bool raw_key)
{
    if (raw_key)
        return settings.value(key);
    return settings.value(prefix_url % QStringLiteral("//") % prefix_uid % QStringLiteral("//") % key);
}

void Settings::setPrefixUid(const QString uid)
{
    prefix_uid = uid;
}

void Settings::setPrefixUrl(const QString url)
{
    prefix_url = url;
    // remove the protocol due to disambiguation in .ini format
    prefix_url.remove(QStringLiteral("https://"));
}

// check if settings is writable and has some required default value
bool Settings::checkSettings()
{
    if (!settings.isWritable()) return false;
    if (!settings.contains("root_url"))
        settings.setValue("root_url", Constants::root_url);

    // set the initial value of prefix_url
    setPrefixUrl(settings.value(QStringLiteral("root_url")).toString());
    return true;
}
