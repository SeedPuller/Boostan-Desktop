#ifndef SCHEDULETABLE_H
#define SCHEDULETABLE_H

#include <QObject>
#include <QVariant>

class ScheduleTable : public QObject
{
    Q_OBJECT

private:

    QMap<QString, QVariantMap> model_data;

public:

    enum collision_errors
    {
        NoCollision = 0,
        ExamCollision,
        TimeCollision,
        ExamWarning
    };

    explicit ScheduleTable(QObject *parent = nullptr);

public slots:
    void addEelement(const QString uid, QVariantMap element);
    void removeEelement(const QString& uid);
    QVariantList checkCollision(const QVariantMap element) const;
    void clearAll();

    /** specialized function member for storing courses **/
    static QString getUid(const int course_number, const int course_group);
    static QString getUid(const QString& course_number, const QString& course_group);

    QString getCourseNames(const QVariantList uids) const;

signals:

};

#endif // SCHEDULETABLE_H
