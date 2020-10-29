#include "header/errors.h"

Errors::Errors(QObject *parent) : QObject(parent), error_code{0}
{

}

QString Errors::getErrorString() const
{
    return Constants::Errors::error_strings[error_code];
}

QString Errors::getErrorSolution() const
{
    return Constants::Errors::error_solutions[error_code];
}

int Errors::getErrorCode() const
{
    return error_code;
}

void Errors::setErrorCode(int ecode)
{
    if (error_code == ecode) return;
    if (ecode >= QNetworkReply::ConnectionRefusedError && ecode <= QNetworkReply::UnknownServerError){
        error_code = Constants::Errors::ServerConnenctionError;
    } else {
        error_code = ecode;
    }
    emit errorCodeChanged();
}

uint Errors::getCriticalStatus() const
{
    if (error_code == Constants::Errors::SettingsError) return status::Critical;
    if (error_code == Constants::Errors::CaptchaStoreError) return status::Critical;
    if (error_code == Constants::Errors::ServerConnenctionError) return status::SemiCritical;
    return status::Normal;
}

void Errors::reset()
{
    setErrorCode(Constants::Errors::NoError);
}
