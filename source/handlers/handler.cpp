#include "header/handlers/handler.h"


Handler::Handler(QObject *parent) : QObject(parent), _is_finished{false}, _success{false}
{
    _root_url = Settings::getValue(QStringLiteral("root_url"), true).toString();
}


void Handler::setCookie(const QString& key, const QString& value)
{
    _cookies[key] = value;
}

/*
    * split 'keyvalue' string into key,value and pass them to setCookie()
*/
void Handler::setCookie(const QString& keyvalue)
{
    QList<QString> splited = keyvalue.split('=');
    QString key {splited.takeFirst()};
    QString value {splited.join('=')};
    setCookie(key, value);
}

QString Handler::getCookies() const
{
    QString data;
    QHashString::const_iterator it = _cookies.cbegin();
    for (; it != _cookies.cend(); ++it) {
        data += it.key() + "=" + it.value() + "; ";
    }
    data.chop(2);
    return data;
}

bool Handler::hasError(QNetworkReply::NetworkError ecode)
{
    // since the ecode is one of the Qt default codes, we should add it to qt_offset
    // to prevent conflict with Golestan error codes.
    setErrorCode(ecode + Errors::qt_offset);
    if (ecode == QNetworkReply::NoError) return false;
    return true;
}

bool Handler::getFinished() const
{
    return _is_finished;
}

void Handler::setFinished(bool value)
{
    _is_finished = value;
    // we only wanna use finished() when an request is finished.
    if (_is_finished == true) emit finished();
    emit workingChanged();
}

bool Handler::getWorking() const
{
    return !_is_finished;
}

uint Handler::getErrorCode() const
{
    return _error_handler.getErrorCode();
}

void Handler::setErrorCode(int ecode)
{
    if (_error_handler.setErrorCode(ecode))
        emit errorCodeChanged();
}

int Handler::getErrorType() const
{
    return _error_handler.getErrorType();
}

QString Handler::getErrorString() const
{
    return _error_handler.getErrorString();
}

QString Handler::getErrorSolution() const
{
    return _error_handler.getErrorSolution();
}

void Handler::setSuccess(bool state)
{
    if (_success == state) return;
    _success = state;
    emit successChanged();
}

bool Handler::getSuccess() const
{
    return _success;
}

void Handler::clearCookies()
{
    _cookies.clear();
}

bool Handler::updateTokens(const QString& data)
{
    QHashString tokens {extractTokens(data)};
    if (tokens.isEmpty()) return false;
    QHashString::iterator it {tokens.begin()};
    // we should remove 'ctck' at every update
    // because we should use ctck only when Golestan says.
    _cookies.remove("ctck");
    for (; it != tokens.end(); ++it) {
        if (it.key() == "tck") continue;
        _cookies[it.key()] = it.value();
    }
    _request_validators["tck"] = tokens["tck"];
    _request_validators[QStringLiteral("uid")] = tokens[QStringLiteral("u")];
    return true;
}

void Handler::clearTokens()
{
    clearCookies();
    _request_validators.clear();
}

bool Handler::verifyResponse(QNetworkReply& reply, QString& data)
{
    if (hasError(reply.error())) {
        return false;
    }
    if (data.isEmpty()) data = reply.readAll();
//    qDebug() << data;
    if (Settings::getValue(QStringLiteral("logging"), true).toBool() == true) {
        Logger::log(QStringLiteral("RECIEVIED: %1").arg(data).toUtf8());
    }

    // try to update the tokens
    bool token_up_res {updateTokens(data)};

    // find out whether we have error or not
    setErrorCode(extractDataError(data));
    if (getErrorCode() != Errors::NoError) {
        return false;
    }

    if (!token_up_res) {
        // we don't know what will gonna prevent updateTokens() to not updating tokens.
        // so the error is unknown and no more progress can be done.
        setErrorCode(Errors::UnknownError);
        return false;
    }

    return true;
}

QHashString Handler::extractFormValidators(const QString& response)
{
    QHashString result;
    int position {response.indexOf(_viewstate_keyword)};
    int endpos;

    if (position == -1) return QHashString {};
    position += 20;
    endpos = response.indexOf('"', position);
    result[QStringLiteral("__VIEWSTATE")] = response.mid(position, endpos - position);

    position = response.indexOf(_viewstate_gen_keyword);
    if (position == -1) return QHashString {};
    position += 29;
    endpos = response.indexOf('"', position);
    result[QStringLiteral("__VIEWSTATEGENERATOR")] = response.mid(position, endpos - position);

    position = response.indexOf(_event_val_keyword);
    if (position == -1) return QHashString {};
    position += 26;
    endpos = response.indexOf('"', position);
    result[QStringLiteral("__EVENTVALIDATION")] = response.mid(position, endpos - position);

//    qDebug() << result;
    return result;
}

QString Handler::getTckToken() const
{
    return _cookies.contains("ctck") ? _cookies.value("ctck") : _request_validators.value("tck");
}

QHashString Handler::extractTokens(const QString& response)
{
    // tokens that Golestan will return at every request and we need these to be able to make
    // another requests.
    QHashString tokens {{QStringLiteral("u"), QString()}, {QStringLiteral("su"), QString()}, {QStringLiteral("ft"), QString()},
                        {QStringLiteral("f"), QString()}, {QStringLiteral("lt"), QString()}, {QStringLiteral("ctck"), QString()},
                        {QStringLiteral("seq"), QString()}, {QStringLiteral("tck"), QString()}};
    QString capture;
    QRegularExpression re {_tokens_pattern};
    QRegularExpressionMatch match {re.match(response)};

    if (!match.hasMatch()) return QHashString {};
    capture = match.captured().remove(QStringLiteral("SavAut(")).remove('\'');
    QStringList splited = capture.split(",");
    // tokens.size() - 1(we dont wanna tck now) = 7
    if (splited.size() < 7) return QHashString {};
    tokens["u"] = splited[0];
    tokens["su"] = splited[1];
    tokens["ft"] = splited[2];
    tokens["f"] = splited[3];
    tokens["lt"] = splited[4];
    tokens["ctck"] = splited[5];
    tokens["seq"] = splited[6];

    /*
        * Normally, 'tck' and 'ctck' are equal to each other and in this case, Golestan only needs 'tck'.
        * But sometimes Golestan explicitly returns tck in other way. in that case we use both 'tck' and 'ctck'
    */
    // check if 'tck' is explicitly defined
    if (!response.contains(QStringLiteral("SetOpenerTck(")) || response.contains(QStringLiteral("SetOpenerTck('')"))) {
        // no 'tck' defined explicitly. use 'ctck' instead and remove 'ctck' from tokens.
        tokens["tck"] = splited[5]; // splited[5] == ctck
        tokens.remove("ctck");
    } else {
        // 'tck' is defined explicitly. we extract that.
        int position {response.indexOf(_tck_keyword)};
        if (position == -1) return QHashString {};
        // 14 is the size of tck_keyword
        position += 14;
        // 16 is the size of tck value.
        tokens["tck"] = response.mid(position, 16);
    }
    return tokens;
}

int Handler::extractDataErrorCode(const QString& response)
{
    // all error codes will come after the word 'code'(in persian)
    int code_position {response.indexOf("کد")};
    QString code;
    if (code_position == -1) return Errors::NoCodeFound;

    // 2 is the length of 'code' in persian. we should skip this to capture actual value.
    int i = code_position + 2;
    while (response[i] != " ") {
        code.append(response[i]);
        ++i;
    }

    return code.toInt();
}
/*
    * This function at first try to extract code from the response.
    * if no code found, then try to find a key word that matches the custom error key words.
*/
int Handler::extractDataError(const QString& response)
{
    if (!response.contains(QStringLiteral("ErrorArr = new Array('"))) return Errors::NoError;
    int code {extractDataErrorCode(response)};
    if (code != Errors::NoCodeFound) return code;
    QHash<int, QString>::const_iterator it {Errors::error_keywords.cbegin()};
    for (; it != Errors::error_keywords.cend(); ++it) {
        if (response.contains(it.value())) {
            // key is a custom error code.
            return it.key();
        }
    }
    // code has error but no corresponding custom error found.
    return Errors::UnknownError;
}
